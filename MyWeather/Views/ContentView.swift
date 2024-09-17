//
//  ContentView.swift
//  MyWeather
//
//  Created by Rock on 14/9/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State private var showLaunchView = true
    @State private var showWeatherView = false

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
                        if showWeatherView {
                            if let weather = weather {
                                WeatherView(weather: weather)
                                    .transition(.opacity) // Fade-in for WeatherView
                            } else {
                                Text("Unable to load weather data.")
                                    .transition(.opacity) // Fade-in for error message
                            }
                        } else {
                            LoadingView()
                                .transition(.opacity) // Fade-in for LoadingView
                                .task {
                                    do {
                                        weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                                        withAnimation(.easeInOut) {
                                            showWeatherView = true
                                        }
                                    } catch {
                                        print("Error getting weather: \(error)")
                                    }
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
                .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .preferredColorScheme(.dark)
            }
        }
        .animation(.easeInOut, value: showLaunchView) // Smooth transition for state changes
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
