# Recording the current MyWeather UI

The README GIF is a real simulator recording. Its data is a genuine OpenWeather
current-weather and 5-day/3-hour forecast capture for public Adelaide coordinates
(-34.9285, 138.6007), replayed locally. It does not demonstrate live in-app HTTP
requests or location permissions. The launch and loading scenes are deliberately
shown before presenting the saved capture. Map tiles may use Apple network access.

## Credential isolation

Set the repository **Actions Secret** `OPENWEATHER_API_KEY`. Never put it in Swift,
a tracked `.env`, a URL in a log, or an uploaded app build. The capture workflow
passes it only to the request step and uploads public weather JSON plus a manifest;
it does not upload the key or an app containing the key. GitHub Secrets are not
retrievable as plaintext through the API.

Run the existing workflow manually (the manual job only captures weather):

```sh
gh workflow run ios.yml --repo RockENZO/MyWeather --ref main
gh run list --repo RockENZO/MyWeather --event workflow_dispatch
# Substitute the completed run's ID; download into a new directory.
gh run download RUN_ID --repo RockENZO/MyWeather \
  --name weather-demo-capture --dir /tmp/myweather-capture
```

Two API requests are made. The key needs access to `/data/2.5/weather` and
`/data/2.5/forecast`. Failed/empty responses stop capture. Credential-bearing
exceptions and response bodies are not printed; echoed secrets and oversized
responses are rejected. Public capture artifacts expire after three days.
The checked-in `demo-capture` directory preserves the responses used in this GIF,
with exact SHA-256 hashes and the acquisition/observation times in `manifest.json`.
Weather data attribution: [OpenWeather](https://openweathermap.org/).

The normal app still uses the existing placeholder API configuration. Creating
an Actions Secret does not automatically configure a locally installed app.
The `--recorded-demo` path is DEBUG-only and contains no API credential.

## Simulator reproduction

Use a simulator runtime compatible with the installed Xcode, and set
`DEVELOPER_DIR` for the commands if Xcode is not globally selected. Create a
disposable simulator; do not erase a personal device. With its UUID as `SIM_ID`:

```sh
xcodebuild -project MyWeather.xcodeproj -scheme MyWeather \
  -destination "id=$SIM_ID" -derivedDataPath /tmp/myweather-build \
  CODE_SIGNING_ALLOWED=NO build-for-testing
xcrun simctl install "$SIM_ID" \
  /tmp/myweather-build/Build/Products/Debug-iphonesimulator/MyWeather.app
APP_DATA=$(xcrun simctl get_app_container "$SIM_ID" rockenzo.MyWeather data)
mkdir -p "$APP_DATA/Documents/WeatherDemo"
cp docs/demo-capture/*.json "$APP_DATA/Documents/WeatherDemo/"
```

Launch with `xcrun simctl launch "$SIM_ID" rockenzo.MyWeather --recorded-demo`,
or record video with `xcrun simctl io "$SIM_ID" recordVideo --codec=h264 recording.mp4`
and run the scripted interactions:

```sh
xcodebuild -project MyWeather.xcodeproj -scheme MyWeather \
  -destination "id=$SIM_ID" -derivedDataPath /tmp/myweather-build \
  -parallel-testing-enabled NO \
  -only-testing:MyWeatherUITests/MyWeatherUITests/testRecordedDemo \
  CODE_SIGNING_ALLOWED=NO test-without-building
```

Stop recording with Ctrl-C. Trim simulator/test-runner startup footage using the
actual video timeline; retain the real app animation, card gestures and capture
attribution. Convert with a generated GIF palette (12 fps, about 402 pixels wide),
inspect normal/expanded/collapsed frames, then replace `SimulatorScreenRecording.gif`.
The UITest asserts the recorded-data attribution and that dragging reveals the
details section; it is not a full UI regression suite.
