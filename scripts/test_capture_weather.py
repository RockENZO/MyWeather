import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch
from urllib.error import HTTPError

spec = importlib.util.spec_from_file_location('capture', Path(__file__).with_name('capture-weather.py'))
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)


class CaptureTests(unittest.TestCase):
    def response(self, data):
        raw = json.dumps(data).encode()
        mock = Mock()
        mock.__enter__ = Mock(return_value=mock)
        mock.__exit__ = Mock(return_value=False)
        mock.read.return_value = raw
        return mock

    def test_capture_has_no_key_and_hashes_exact_response_bytes(self):
        key = 'test-only-secret-abcdefgh'
        weather = {'cod': 200, 'weather': [{}], 'dt': 100}
        forecast = {'cod': '200', 'list': [{}]}
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'capture'
            with patch.object(capture, 'urlopen', side_effect=[self.response(weather), self.response(forecast)]):
                capture.capture(output, key)
            manifest = json.loads((output / 'manifest.json').read_text())
            for path in output.iterdir():
                self.assertNotIn(key.encode(), path.read_bytes())
            for name, digest in manifest['sha256'].items():
                self.assertEqual(hashlib.sha256((output / name).read_bytes()).hexdigest(), digest)
            self.assertEqual(manifest['weather_observed_at'], 100)

    def test_missing_key_makes_no_request(self):
        with patch.object(capture, 'urlopen') as request:
            with self.assertRaises(capture.CaptureError):
                capture.capture('unused', '')
        request.assert_not_called()

    def test_http_error_does_not_disclose_key_in_url(self):
        key = 'test-only-secret-abcdefgh'
        error = HTTPError('https://example.com/?appid=' + key, 401, key, {}, None)
        with patch.object(capture, 'urlopen', side_effect=error):
            with self.assertRaises(capture.CaptureError) as raised:
                capture.capture('unused', key)
        self.assertNotIn(key, str(raised.exception))

    def test_echoed_secret_cannot_enter_artifacts(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'capture'
            with patch.object(capture, 'urlopen', return_value=self.response({'cod': 200, 'message': 'test-secret-123'})):
                with self.assertRaises(capture.CaptureError):
                    capture.capture(output, 'test-secret-123')
            self.assertFalse(output.exists())

    def test_failed_second_request_produces_no_artifacts(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'capture'
            with patch.object(capture, 'urlopen', side_effect=[self.response({'cod': 200, 'weather': [{}], 'dt': 100}), self.response({'cod': '401'})]):
                with self.assertRaises(capture.CaptureError):
                    capture.capture(output, 'test-secret')
            self.assertFalse(output.exists())

    def test_main_prints_only_sanitized_error(self):
        output = io.StringIO()
        with patch.object(capture.sys, 'argv', ['capture-weather', '--output', 'unused']), patch.dict(capture.os.environ, {'OPENWEATHER_API_KEY': ''}), contextlib.redirect_stderr(output):
            self.assertEqual(capture.main(), 1)
        self.assertIn('not configured', output.getvalue())
