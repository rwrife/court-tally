import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).parents[1] / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


release = load('release', 'app_store_release.py')
verify = load('verify', 'verify-release.py')


class ReleaseTests(unittest.TestCase):
    def test_der_signature_accepts_padded_integers(self):
        r = bytes([0, 0x80]) + bytes(31)
        s = bytes([1])
        body = b'\x02' + bytes([len(r)]) + r + b'\x02\x01' + s
        result = release.der_to_raw(b'\x30' + bytes([len(body)]) + body)
        self.assertEqual(result, r[1:] + bytes(31) + s)

    def test_der_signature_rejects_malformed_data(self):
        for data in [b'', b'\x30\x06\x02\x01\x80\x02\x01\x01', b'\x30\x08\x02\x01\x01\x02\x01\x01']:
            with self.assertRaises(ValueError):
                release.der_to_raw(data)

    def metadata(self, **environment):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'outputs'
            env = {'GITHUB_REF': 'refs/heads/main', 'GITHUB_RUN_NUMBER': '5', 'GITHUB_RUN_ATTEMPT': '2',
                   'INPUT_VERSION': '1.2.3', 'GITHUB_OUTPUT': str(output)}
            env.update(environment)
            with patch.dict(os.environ, env, clear=True):
                release.release_metadata()
            return output.read_text()

    def test_unique_build_attempt_and_version(self):
        self.assertEqual(self.metadata(), 'version=1.2.3\nbuild=1005.2\n')

    def test_tag_wins_over_input(self):
        self.assertIn('version=2.0.0', self.metadata(GITHUB_REF='refs/tags/v2.0.0'))

    def test_rejects_shell_injection_and_invalid_build_numbers(self):
        for change in [{'INPUT_VERSION': '1.2.3; echo bad'}, {'GITHUB_RUN_NUMBER': '9000'}, {'GITHUB_RUN_ATTEMPT': '100'}]:
            with self.assertRaises(ValueError):
                self.metadata(**change)

    def test_exported_info_rejects_old_bundle_and_ipad(self):
        info = {'CFBundleIdentifier': release.BUNDLE_ID, 'CFBundleVersion': '1005.2', 'CFBundleShortVersionString': '1.2.3', 'UIDeviceFamily': [1]}
        verify.validate_info(info, '1.2.3', '1005.2')
        for changes in [{'UIDeviceFamily': [1, 2]}, {'CFBundleIdentifier': 'com.rwrife.courttally'}, {'CFBundleVersion': '1'}]:
            with self.assertRaises(ValueError):
                verify.validate_info(info | changes, '1.2.3', '1005.2')

    def test_cleanup_only_deletes_its_own_resources(self):
        with tempfile.TemporaryDirectory() as directory:
            signing = release.Signing.__new__(release.Signing)
            signing.folder = Path(directory)
            signing.state_path = signing.folder / 'state.json'
            signing.state = {'certificate_id': 'our-cert', 'profile_id': 'our-profile'}
            signing.request = Mock()
            signing.save()
            (signing.folder / 'AuthKey_test.p8').write_text('test-only')
            signing.cleanup()
            self.assertEqual(signing.request.call_args_list[0].args, ('DELETE', 'profiles/our-profile'))
            self.assertEqual(signing.request.call_args_list[1].args, ('DELETE', 'certificates/our-cert'))
            self.assertEqual(signing.request.call_count, 2)
            self.assertEqual(list(signing.folder.iterdir()), [])

    def test_cleanup_removes_local_keys_even_if_api_cleanup_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            signing = release.Signing.__new__(release.Signing)
            signing.folder = Path(directory)
            signing.state_path = signing.folder / 'state.json'
            signing.state = {'certificate_id': 'our-cert'}
            signing.request = Mock(side_effect=RuntimeError('Apple unavailable'))
            signing.save()
            key = signing.folder / 'AuthKey_test.p8'
            key.write_text('test-only')
            with self.assertRaises(RuntimeError):
                signing.cleanup()
            self.assertFalse(key.exists())
            self.assertEqual(json.loads(signing.state_path.read_text())['certificate_id'], 'our-cert')


    def test_unconfirmed_upload_keeps_remote_certificate_but_removes_local_key(self):
        with tempfile.TemporaryDirectory() as directory:
            signing = release.Signing.__new__(release.Signing)
            signing.folder = Path(directory)
            signing.state_path = signing.folder / 'state.json'
            signing.state = {'certificate_id': 'our-cert', 'profile_id': 'our-profile', 'upload_pending': True}
            signing.request = Mock()
            signing.save()
            key = signing.folder / 'AuthKey_test.p8'
            key.write_text('test-only')
            with self.assertRaises(RuntimeError):
                signing.cleanup()
            signing.request.assert_not_called()
            self.assertFalse(key.exists())

    def test_processing_valid_allows_signing_cleanup(self):
        signing = release.Signing.__new__(release.Signing)
        signing.state = {'upload_pending': True}
        signing.save = Mock()
        signing.request = Mock(return_value={'data': [{'attributes': {'processingState': 'VALID'}}]})
        with patch.dict(os.environ, {'ASC_APP_ID': '123', 'RELEASE_BUILD': '1001.1'}):
            signing.wait_processing(timeout=1)
        self.assertFalse(signing.state['upload_pending'])
        signing.save.assert_called_once()

    def test_processing_timeout_does_not_revoke_signing(self):
        signing = release.Signing.__new__(release.Signing)
        signing.state = {'upload_pending': True}
        signing.request = Mock()
        with patch.dict(os.environ, {'ASC_APP_ID': '123', 'RELEASE_BUILD': '1001.1'}):
            with self.assertRaises(RuntimeError):
                signing.wait_processing(timeout=0)
        self.assertTrue(signing.state['upload_pending'])


if __name__ == '__main__':
    unittest.main()
