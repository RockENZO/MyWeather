#!/bin/bash
set -euo pipefail
# Run on a disposable CI runner with Xcode; no API credential is needed.
: "${RUNNER_TEMP:?This script expects a disposable GitHub runner}"
output="$RUNNER_TEMP/MyWeatherRecording"
build="$RUNNER_TEMP/MyWeatherDemoBuild"
mkdir -p "$output"
runtime=$(xcrun simctl list runtimes --json | python3 -c 'import json,sys; r=[r for r in json.load(sys.stdin)["runtimes"] if r.get("isAvailable") and ".iOS-" in r["identifier"]]; print(max(r,key=lambda r:tuple(map(int,r["version"].split("."))))["identifier"])')
sim_id=$(xcrun simctl create MyWeatherRecording com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro "$runtime")
record_pid=''
cleanup() {
  if [[ -n "$record_pid" ]]; then kill -INT "$record_pid" 2>/dev/null || true; wait "$record_pid" || true; fi
  xcrun simctl shutdown "$sim_id" 2>/dev/null || true
  xcrun simctl delete "$sim_id" 2>/dev/null || true
}
trap cleanup EXIT
xcrun simctl boot "$sim_id"
xcrun simctl bootstatus "$sim_id" -b
xcodebuild -project MyWeather.xcodeproj -scheme MyWeather \
  -destination "id=$sim_id" -derivedDataPath "$build" \
  CODE_SIGNING_ALLOWED=NO build-for-testing > "$output/build.log" 2>&1
xcrun simctl install "$sim_id" "$build/Build/Products/Debug-iphonesimulator/MyWeather.app"
app_data=$(xcrun simctl get_app_container "$sim_id" rockenzo.MyWeather data)
mkdir -p "$app_data/Documents/WeatherDemo"
cp "$RUNNER_TEMP/WeatherDemo/"*.json "$app_data/Documents/WeatherDemo/"
xcrun simctl ui "$sim_id" appearance dark
xcrun simctl io "$sim_id" recordVideo --codec=h264 "$output/recording.mp4" > "$output/recorder.log" 2>&1 &
record_pid=$!
sleep 2
xcodebuild -project MyWeather.xcodeproj -scheme MyWeather \
  -destination "id=$sim_id" -derivedDataPath "$build" \
  -resultBundlePath "$output/interaction.xcresult" \
  -parallel-testing-enabled NO \
  -only-testing:MyWeatherUITests/MyWeatherUITests/testRecordedDemo \
  CODE_SIGNING_ALLOWED=NO test-without-building > "$output/test.log" 2>&1
kill -INT "$record_pid"
wait "$record_pid"
record_pid=''
cp "$RUNNER_TEMP/WeatherDemo/manifest.json" "$output/capture-manifest.json"
