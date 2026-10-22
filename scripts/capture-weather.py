"""Capture public Adelaide weather on a runner; never export the API secret."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen


class CaptureError(Exception):
    pass


def capture(output, key):
    if not key or not key.strip():
        raise CaptureError('OPENWEATHER_API_KEY is not configured.')
    payloads = {}
    for endpoint, filename in [('weather', 'weather.json'), ('forecast', 'forecast.json')]:
        query = urlencode({'lat': -34.9285, 'lon': 138.6007, 'units': 'metric', 'appid': key})
        try:
            with urlopen('https://api.openweathermap.org/data/2.5/' + endpoint + '?' + query, timeout=30) as response:
                raw = response.read(1_048_577)
            if len(raw) > 1_048_576 or key.encode() in raw:
                raise CaptureError('Response exceeded limits or contained credential material.')
            data = json.loads(raw)
            if str(data.get('cod')) != '200':
                raise CaptureError('Weather service did not return a successful result.')
            if endpoint == 'weather' and (not data.get('weather') or not isinstance(data.get('dt'), int)):
                raise CaptureError('Current weather is missing observations.')
            if endpoint == 'forecast' and not data.get('list'):
                raise CaptureError('Forecast is empty.')
        except (HTTPError, URLError, TimeoutError, ValueError, AttributeError):
            # Exception text/URLs and response bodies can contain the API key.
            raise CaptureError('Weather request failed; check key activation and API access.') from None
        payloads[filename] = raw
    weather = json.loads(payloads['weather.json'])
    manifest = {
        'version': 1, 'source': 'OpenWeather', 'location': 'Adelaide, AU',
        'latitude': -34.9285, 'longitude': 138.6007, 'units': 'metric',
        'captured_at_utc': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
        'weather_observed_at': weather['dt'],
        'sha256': {name: hashlib.sha256(raw).hexdigest() for name, raw in payloads.items()},
        'scope': 'Recorded API responses; replayed for UI recording, not a live connection.',
    }
    output = Path(output)
    output.mkdir(parents=True, exist_ok=False)
    for name, raw in payloads.items():
        with (output / name).open('xb') as stream:
            stream.write(raw)
    with (output / 'manifest.json').open('x') as stream:
        json.dump(manifest, stream, indent=2)
        stream.write('\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    try:
        capture(args.output, os.environ.get('OPENWEATHER_API_KEY', ''))
    except CaptureError as error:
        print(str(error), file=sys.stderr)
        return 1
    print('Captured public Adelaide observations and forecast; no API key exported.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
