//
//  WelcomeView.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//

import SwiftUI
import CoreLocationUI


struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    var body: some View {
        VStack{
            VStack(spacing: 20){
                Text("Welcome to MyWeather").bold().font(.title)
                Text("Please share your current location to get the weather in your area").padding()
            }
            .multilineTextAlignment(.center)
            .padding()
            
            LocationButton(.shareCurrentLocation){
                locationManager.requestLocation()
            }
            .cornerRadius(30)
            .symbolVariant(.fill)
            .foregroundColor(.white)
        }
        .frame(maxWidth:.infinity, maxHeight:.infinity)
    }
}

#Preview {
    WelcomeView()
}
