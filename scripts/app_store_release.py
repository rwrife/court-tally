#!/usr/bin/env python3
"""Prepare and clean ephemeral App Store signing assets on GitHub-hosted macOS.

Uses Python's standard library, OpenSSL, and Apple's security tool. The existing
ASC API key never leaves the runner except as a signed JWT sent to Apple.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import secrets
import shlex
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

BUNDLE_ID = "com.infinityball.courttally"
API_ROOT = "https://api.appstoreconnect.apple.com/v1/"


def run(*args, input_data=None):
    result = subprocess.run(args, input=input_data, capture_output=True)
    if result.returncode:
        # Do not include command arguments: security arguments contain passwords.
        raise RuntimeError(f"{Path(args[0]).name} failed: {result.stderr.decode(errors='replace').strip()}")
    return result.stdout


def b64url(data):
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def der_to_raw(signature):
    """Convert OpenSSL's P-256 ECDSA DER signature to JOSE's 64-byte R || S."""
    if len(signature) < 8 or signature[0] != 0x30 or signature[1] != len(signature) - 2:
        raise ValueError("Invalid ECDSA signature sequence")
    values, offset = [], 2
    for _ in range(2):
        if offset + 2 > len(signature) or signature[offset] != 0x02:
            raise ValueError("Invalid ECDSA signature integer")
        length = signature[offset + 1]
        value = signature[offset + 2:offset + 2 + length]
        if len(value) != length or not value or value[0] & 0x80:
            raise ValueError("Invalid ECDSA signature integer length")
        number = int.from_bytes(value, "big")
        values.append(number.to_bytes(32, "big"))
        offset += length + 2
    if offset != len(signature):
        raise ValueError("Trailing ECDSA signature data")
    return b"".join(values)


def private_file(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    path.chmod(0o600)


def emit(name, value):
    if "\n" in str(value) or "\r" in str(value):
        raise ValueError("Invalid multiline workflow output")
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            output.write(f"{name}={value}\n")


def release_metadata():
    ref = os.environ.get("GITHUB_REF", "")
    version = ref[11:] if ref.startswith("refs/tags/v") else os.environ.get("INPUT_VERSION", "").strip()
    if not version:
        project = Path("ios-native/CourtTally.xcodeproj/project.pbxproj").read_text()
        version = re.search(r'MARKETING_VERSION = "?([0-9.]+)"?;', project).group(1)
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
        raise ValueError("Version must have the form 1.2.3; release tags must be v1.2.3")
    number = int(os.environ.get("IOS_BUILD_NUMBER_BASE") or "1000") + int(os.environ["GITHUB_RUN_NUMBER"])
    attempt = int(os.environ["GITHUB_RUN_ATTEMPT"])
    if not 1 <= number <= 9999 or not 1 <= attempt <= 99:
        raise ValueError("Build number exceeds Apple's digit limits; adjust IOS_BUILD_NUMBER_BASE")
    build = f"{number}.{attempt}"
    emit("version", version)
    emit("build", build)
    print(f"Preparing Court Tally {version} ({build}) for {BUNDLE_ID}")


class Signing:
    def __init__(self):
        self.folder = Path(os.environ["RUNNER_TEMP"]) / "court-tally-signing"
        self.folder.mkdir(parents=True, exist_ok=True, mode=0o700)
        self.state_path = self.folder / "state.json"
        self.state = json.loads(self.state_path.read_text()) if self.state_path.exists() else {}
        self.key_id = os.environ["ASC_KEY_ID"].strip()
        self.issuer = os.environ["ASC_ISSUER_ID"].strip()
        self.team = os.environ["ASC_TEAM_ID"].strip()
        if not re.fullmatch(r"[A-Za-z0-9]+", self.key_id) or not re.fullmatch(r"[A-Za-z0-9]{10}", self.team):
            raise ValueError("Check ASC_KEY_ID and ASC_TEAM_ID")
        self.auth_key = self.folder / f"AuthKey_{self.key_id}.p8"
        value = os.environ["ASC_KEY_P8"].strip()
        if "-----BEGIN PRIVATE KEY-----" in value:
            raw = value.replace("\\n", "\n").encode()
        else:
            raw = base64.b64decode(value, validate=True)
        private_file(self.auth_key, raw)

    def save(self):
        private_file(self.state_path, json.dumps(self.state).encode())

    def request(self, method, path, body=None):
        header = b64url(json.dumps({"alg": "ES256", "kid": self.key_id, "typ": "JWT"}).encode())
        issued = int(time.time())
        payload = b64url(json.dumps({"iss": self.issuer, "iat": issued, "exp": issued + 600, "aud": "appstoreconnect-v1"}).encode())
        message = f"{header}.{payload}"
        signature = der_to_raw(run("openssl", "dgst", "-sha256", "-sign", str(self.auth_key), input_data=message.encode()))
        token = f"{message}.{b64url(signature)}"
        request = urllib.request.Request(API_ROOT + path, method=method,
            data=None if body is None else json.dumps(body).encode(),
            headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                data = response.read()
                return json.loads(data) if data else {}
        except urllib.error.HTTPError as error:
            if method == "DELETE" and error.code == 404:
                return {}
            try:
                details = json.loads(error.read()).get("errors", [])
                detail = "; ".join(item.get("detail", item.get("title", "")) for item in details)
            except (ValueError, TypeError):
                detail = "Unexpected response from Apple"
            raise RuntimeError(f"Apple API {method} {path.split('?')[0]} returned {error.code}: {detail}") from None

    def prepare(self):
        apps = self.request("GET", "apps?" + urllib.parse.urlencode({"filter[bundleId]": BUNDLE_ID}))['data']
        emit("app_present", str(bool(apps)).lower())
        emit("app_id", apps[0]["id"] if apps else "")
        if os.environ.get("WANT_UPLOAD") == "true" and not apps:
            raise RuntimeError(f"Create an iOS app record for {BUNDLE_ID} in App Store Connect before uploading. No signing certificate was created.")
        if not apps:
            print("No App Store Connect app record yet. This run can build an IPA; create the app record before choosing upload.")
        bundles = self.request("GET", "bundleIds?" + urllib.parse.urlencode({"filter[identifier]": BUNDLE_ID, "filter[platform]": "IOS"}))['data']
        if bundles:
            bundle = bundles[0]
        else:
            bundle = self.request("POST", "bundleIds", {"data": {"type": "bundleIds", "attributes": {
                "identifier": BUNDLE_ID, "name": "Court Tally", "platform": "IOS"}}})['data']
            print("Registered the requested bundle identifier with Apple.")
        keychain = self.folder / "release.keychain-db"
        password = secrets.token_urlsafe(32)
        self.state['keychain'] = str(keychain)
        self.state['previous_keychains'] = shlex.split(run("security", "list-keychains", "-d", "user").decode())
        self.save()
        run("security", "create-keychain", "-p", password, str(keychain))
        run("security", "set-keychain-settings", "-lut", "21600", str(keychain))
        run("security", "unlock-keychain", "-p", password, str(keychain))
        run("security", "list-keychains", "-d", "user", "-s", str(keychain), *self.state['previous_keychains'])
        key, csr = self.folder / "distribution.key", self.folder / "distribution.csr"
        run("openssl", "req", "-new", "-newkey", "rsa:2048", "-nodes", "-keyout", str(key), "-out", str(csr), "-subj", "/CN=Court Tally GitHub Actions/")
        key.chmod(0o600)
        cert = self.request("POST", "certificates", {"data": {"type": "certificates", "attributes": {
            "certificateType": "DISTRIBUTION", "csrContent": csr.read_text()}}})['data']
        self.state['certificate_id'] = cert['id']
        self.save()  # Record only resources created by this run before any following operation.
        der = base64.b64decode(cert['attributes']['certificateContent'])
        der_path, pem_path, p12 = self.folder / "distribution.cer", self.folder / "distribution.pem", self.folder / "distribution.p12"
        private_file(der_path, der)
        run("openssl", "x509", "-inform", "DER", "-in", str(der_path), "-out", str(pem_path))
        # macOS security requires a nonempty PKCS#12 password for reliable import.
        p12_password = secrets.token_urlsafe(32)
        run("openssl", "pkcs12", "-export", "-inkey", str(key), "-in", str(pem_path), "-out", str(p12), "-passout", "pass:" + p12_password, "-keypbe", "PBE-SHA1-3DES", "-certpbe", "PBE-SHA1-3DES", "-macalg", "sha1")
        run("security", "import", str(p12), "-k", str(keychain), "-P", p12_password, "-T", "/usr/bin/codesign", "-T", "/usr/bin/security")
        run("security", "set-key-partition-list", "-S", "apple-tool:,apple:", "-k", password, str(keychain))
        profile = self.request("POST", "profiles", {"data": {"type": "profiles", "attributes": {
            "name": f"Court Tally CI {os.environ['GITHUB_RUN_ID']}-{os.environ['GITHUB_RUN_ATTEMPT']}", "profileType": "IOS_APP_STORE"},
            "relationships": {"bundleId": {"data": {"type": "bundleIds", "id": bundle['id']}},
                              "certificates": {"data": [{"type": "certificates", "id": cert['id']}]}}}})['data']
        self.state['profile_id'] = profile['id']
        self.save()
        profile_data = base64.b64decode(profile['attributes']['profileContent'])
        profile_path = self.folder / "distribution.mobileprovision"
        private_file(profile_path, profile_data)
        details = plistlib.loads(run("security", "cms", "-D", "-i", str(profile_path)))
        profile_uuid = details['UUID']
        if details['TeamIdentifier'] != [self.team] or details['Entitlements']['application-identifier'] != f"{self.team}.{BUNDLE_ID}":
            raise RuntimeError("The returned profile does not match ASC_TEAM_ID and the requested bundle ID")
        self.state['installed_profiles'] = []
        for location in ["Library/MobileDevice/Provisioning Profiles", "Library/Developer/Xcode/UserData/Provisioning Profiles"]:
            destination = Path.home() / location / f"{profile_uuid}.mobileprovision"
            if destination.exists():
                raise RuntimeError("Refusing to overwrite a pre-existing provisioning profile")
            self.state['installed_profiles'].append(str(destination)); self.save()
            private_file(destination, profile_data)
        fingerprint = hashlib.sha1(der).hexdigest().upper()
        export = {"method": "app-store-connect", "destination": "export", "signingStyle": "manual", "teamID": self.team,
                  "signingCertificate": fingerprint, "provisioningProfiles": {BUNDLE_ID: profile_uuid},
                  "manageAppVersionAndBuildNumber": False, "stripSwiftSymbols": True, "uploadSymbols": True}
        options = self.folder / "ExportOptions.plist"
        options.write_bytes(plistlib.dumps(export))
        emit("profile_uuid", profile_uuid); emit("certificate_sha1", fingerprint)
        emit("export_options", options); emit("auth_key", self.auth_key)
        print("Temporary distribution certificate, keychain, and App Store provisioning profile are ready.")

    def mark_upload(self):
        self.state['upload_pending'] = True
        self.save()

    def wait_processing(self, timeout=1800):
        query = urllib.parse.urlencode({"filter[app]": os.environ['ASC_APP_ID'],
                                       "filter[version]": os.environ['RELEASE_BUILD'], "limit": 1})
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            builds = self.request("GET", "builds?" + query)['data']
            state = builds[0]['attributes']['processingState'] if builds else 'NOT_VISIBLE'
            if state in ('VALID', 'FAILED', 'INVALID'):
                self.state['upload_pending'] = False
                self.save()
                if state != 'VALID':
                    raise RuntimeError(f"Apple build processing ended with {state}. Check App Store Connect for details.")
                print("Apple finished processing the uploaded build successfully.")
                return
            print(f"Apple build processing: {state}", flush=True)
            time.sleep(30)
        raise RuntimeError("Apple processing was not confirmed within 30 minutes. Signing assets will be retained pending verification.")

    def cleanup(self):
        errors = []
        resources = [("profile_id", "profiles"), ("certificate_id", "certificates")]
        if self.state.get('upload_pending'):
            resources = []
            errors.append("Upload processing is unconfirmed. Retained this run's remote signing assets; check Apple before removing them.")
        for state_key, resource in resources:
            if self.state.get(state_key):
                try:
                    self.request("DELETE", f"{resource}/{self.state[state_key]}")
                    del self.state[state_key]; self.save()
                except Exception as error:
                    errors.append(str(error))
        for profile in self.state.get('installed_profiles', []):
            Path(profile).unlink(missing_ok=True)
        if self.state.get('previous_keychains'):
            try:
                run("security", "list-keychains", "-d", "user", "-s", *self.state['previous_keychains'])
            except RuntimeError as error:
                errors.append(str(error))
        if self.state.get('keychain') and Path(self.state['keychain']).exists():
            try:
                run("security", "delete-keychain", self.state['keychain'])
            except RuntimeError as error:
                errors.append(str(error))
        # Always remove local secret material, even if Apple's cleanup endpoint fails.
        for name in self.folder.iterdir():
            if name.is_file() and name != self.state_path:
                name.unlink()
        if errors:
            print("Resources requiring manual cleanup:", json.dumps({k: v for k, v in self.state.items() if k.endswith('_id')}))
            raise RuntimeError("; ".join(errors))
        self.state_path.unlink(missing_ok=True)
        print("Removed this run's signing certificate, profile, keychain, and private key files.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['metadata', 'prepare', 'cleanup', 'mark-upload', 'wait-processing'])
    command = parser.parse_args().command
    if command == 'metadata':
        release_metadata()
    else:
        os.umask(0o077)
        signing = Signing()
        getattr(signing, command.replace('-', '_'))()


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f"::error::{error}", file=sys.stderr)
        sys.exit(1)
