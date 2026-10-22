//
//  MyWeatherApp.swift
//  MyWeather
//
//  Created by Rock on 14/9/2024.
//

import SwiftUI

@main
struct MyWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--recorded-demo") {
                RecordedWeatherDemo()
            } else {
                ContentView()
            }
            #else
            ContentView()
            #endif
        }
    }
}

#if DEBUG
/// Replays genuine API responses copied into the simulator's Documents/WeatherDemo.
/// The capture contains public weather data, never the API key.
private struct RecordedWeatherDemo: View {
    @State private var phase = 0
    @State private var snapshot: DemoSnapshot?
    @State private var failed = false

    var body: some View {
        Group {
            if failed {
                Text("Demo capture unavailable. See recording instructions.")
                    .accessibilityIdentifier("demo-error")
            } else if phase == 0 {
                LaunchView()
            } else if phase == 1 {
                LoadingView()
            } else if let snapshot = snapshot {
                WeatherView(weather: snapshot.weather, forecast: snapshot.forecast,
                            observationDate: Date(timeIntervalSince1970: snapshot.manifest.weather_observed_at))
                    .safeAreaInset(edge: .bottom) {
                        Text("OpenWeather · recorded capture\n" + snapshot.manifest.captured_at_utc)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(6)
                            .background(Color.black.opacity(0.9))
                            .accessibilityIdentifier("demo-attribution")
                    }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            do {
                snapshot = try DemoSnapshot.load()
                try await Task.sleep(nanoseconds: 2_000_000_000)
                phase = 1
                try await Task.sleep(nanoseconds: 1_000_000_000)
                phase = 2
            } catch is CancellationError {
                return
            } catch {
                failed = true
            }
        }
    }
}

private struct DemoSnapshot {
    struct Manifest: Decodable {
        let captured_at_utc: String
        let weather_observed_at: Double
    }
    let weather: ResponseBody
    let forecast: ForecastResponse
    let manifest: Manifest

    static func load() throws -> DemoSnapshot {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WeatherDemo", isDirectory: true)
        let decoder = JSONDecoder()
        func decode<T: Decodable>(_ name: String) throws -> T {
            try decoder.decode(T.self, from: Data(contentsOf: directory.appendingPathComponent(name)))
        }
        return try DemoSnapshot(weather: decode("weather.json"),
                                forecast: decode("forecast.json"),
                                manifest: decode("manifest.json"))
    }
}
#endif
