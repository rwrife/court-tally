#!/usr/bin/env python3
"""Check the final exported IPA, not just the source project's settings."""
import json
import os
from pathlib import Path
import plistlib
import subprocess
import zipfile


def validate_info(info, version, build):
    expected = {
        'CFBundleIdentifier': 'com.infinityball.courttally',
        'CFBundleShortVersionString': version,
        'CFBundleVersion': build,
        'UIDeviceFamily': [1],
    }
    for key, value in expected.items():
        if info.get(key) != value:
            raise ValueError(f'{key}: expected {value!r}, got {info.get(key)!r}')
    if 'UISupportedInterfaceOrientations~ipad' in info:
        raise ValueError('Exported app still contains iPad-specific orientation settings')


def main():
    root = Path('build/release')
    ipa = root / 'export/CourtTally.ipa'
    destination = root / 'verified'
    with zipfile.ZipFile(ipa) as archive:
        for member in archive.namelist():
            resolved = (destination / member).resolve()
            if not resolved.is_relative_to(destination.resolve()):
                raise ValueError('Invalid archive member path')
    subprocess.check_call(['ditto', '-x', '-k', str(ipa), str(destination)])
    app = destination / 'Payload/CourtTally.app'
    info = plistlib.loads((app / 'Info.plist').read_bytes())
    validate_info(info, os.environ['RELEASE_VERSION'], os.environ['RELEASE_BUILD'])
    profile = plistlib.loads(subprocess.check_output(['security', 'cms', '-D', '-i', str(app / 'embedded.mobileprovision')]))
    expected = os.environ['ASC_TEAM_ID'] + '.com.infinityball.courttally'
    if profile['Entitlements']['application-identifier'] != expected or profile['Entitlements'].get('get-task-allow', False):
        raise ValueError('Exported app does not have the expected distribution provisioning')
    if profile.get('ProvisionedDevices') or profile.get('ProvisionsAllDevices'):
        raise ValueError('Expected App Store distribution, not ad hoc or enterprise signing')
    metadata = {
        'bundleId': info['CFBundleIdentifier'], 'version': info['CFBundleShortVersionString'],
        'build': info['CFBundleVersion'], 'deviceFamily': info['UIDeviceFamily'],
        'commit': os.environ.get('GITHUB_SHA'), 'runId': os.environ.get('GITHUB_RUN_ID'),
    }
    (root / 'release.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print('Verified exported iPhone IPA, version, build number, and distribution profile.')


if __name__ == '__main__':
    main()
