//
//  ContentView.swift
//  MyWeather
//
//  Created by Rock on 14/9/2024.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State var forecast: ForecastResponse?
    @State private var showLaunchView = true
    @State private var showWeatherView = false
    @State private var weatherError: String?
    @State private var isLoadingWeather = false

    var body: some View {
        ZStack {
            if showLaunchView {
                LaunchView()
                    .transition(.opacity) // Smooth fade-in/fade-out transition
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.showLaunchView = false
                            }
                        }
                    }
            } else {
                VStack {
                    if let location = locationManager.location {
                        if showWeatherView, let weather = weather, let forecast = forecast {
                            WeatherView(weather: weather, forecast: forecast)
                                .transition(.opacity) // Fade-in for WeatherView
                        } else if let weatherError {
                            WeatherErrorView(message: weatherError) {
                                Task { await loadWeather(for: location) }
                            }
                            .transition(.opacity)
                        } else {
                            LoadingView()
                                .transition(.opacity) // Fade-in for LoadingView
                                .task {
                                    await loadWeather(for: location)
                                }
                        }
                    } else {
                        if locationManager.isLoading {
                            LoadingView()
                                .transition(.opacity) // Fade-in for LoadingView
                        } else {
                            WelcomeView()
                                .environmentObject(locationManager)
                                .transition(.opacity) // Fade-in for WelcomeView
                        }
                    }
                }
                .glassBackground(tint: .primary, opacity: 0.18)
                .preferredColorScheme(.dark)
            }
        }
        .animation(.easeInOut, value: showLaunchView) // Smooth transition for state changes
        .animation(.easeInOut, value: weatherError)
    }

    /// A failed request must leave the loading view instead of spinning forever.
    /// The retry action reuses the same request path and keeps the last error
    /// visible until a request succeeds.
    private func loadWeather(for location: CLLocationCoordinate2D) async {
        guard !isLoadingWeather else { return }
        isLoadingWeather = true
        weatherError = nil
        defer { isLoadingWeather = false }
        do {
            let current = try await weatherManager.getCurrentWeather(
                latitude: location.latitude, longitude: location.longitude)
            let days = try await weatherManager.getWeatherForecast(
                latitude: location.latitude, longitude: location.longitude)
            withAnimation(.easeInOut) {
                weather = current
                forecast = days
                showWeatherView = true
            }
        } catch {
            weatherError = "We couldn't load the weather. Check your connection and try again."
        }
    }
}

struct WeatherErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.slash")
                .font(.system(size: 44))
                .foregroundColor(.glassText)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.glassText)
                .padding(.horizontal, 28)
            Button(action: retry) {
                Text("Try again")
                    .bold()
                    .padding(.horizontal, 26)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.25))
            .foregroundColor(.glassText)
            .accessibilityHint("Requests the current weather and forecast again")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
