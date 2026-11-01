//
//  WelcomeView.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//

import SwiftUI
import CoreLocationUI
import CoreLocation
import UIKit

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager

    private var permissionDenied: Bool {
        locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
    }

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Welcome to MyWeather")
                    .bold()
                    .font(.title)
                Text(permissionDenied
                     ? "Location access is off, so local weather can't be shown. Enable it in Settings to continue."
                     : "Share your current location to get the weather in your area🗺️")
                    .bold()
                    .padding()
            }
            .multilineTextAlignment(.center)
            .padding()

            if permissionDenied {
                Button {
                    openSettings()
                } label: {
                    Text("Open Settings")
                        .bold()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.25))
                .foregroundColor(.glassText)
                .accessibilityHint("Opens the MyWeather permission settings")
            } else {
                LocationButton(.shareCurrentLocation) {
                    locationManager.requestLocation()
                }
                .cornerRadius(30)
                .symbolVariant(.fill)
                .foregroundColor(.glassText)

                if let error = locationManager.lastError {
                    Text(error)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.glassText)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.7)]), // Adjusted brightness
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(.dark)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    WelcomeView()
}
