//
//  LocationManger.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: String?

    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
    }
    func requestLocation() {
        lastError = nil
        isLoading = true
        manager.requestLocation()
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            // requestLocation() cannot recover from a denied permission; stop the
            // spinner and let the UI explain how to enable it in Settings.
            isLoading = false
            lastError = "Location access is off. Enable it in Settings to see your local weather."
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        lastError = nil
        isLoading = false
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error getting location", error)
        isLoading = false
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            lastError = "Location access is off. Enable it in Settings to see your local weather."
        } else {
            lastError = "Couldn't determine your location. Check your connection and try again."
        }
    }
}
