//
//  WeatherRow.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//


import SwiftUI

struct WeatherRow: View {
    var logo: String
    var name: String
    var value: String
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                // Circle Background
                Circle()
                    .fill(Color(hue: 0.656, saturation: 0.787, brightness: 1.04)) // Adjust color for contrast
                    .frame(width: 60, height: 60) // Adjust size if needed
                    .shadow(radius: 5) // Optional: add shadow to enhance visibility
                
                // Gradient Icon
                Image(systemName: logo)
                    .font(.title2)
                    .frame(width: 30, height: 30)
                    .padding(8) // Add padding if necessary
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hue: 0.656, saturation: 0.787, brightness: 0.654), // Light color
                                Color(hue: 0.656, saturation: 0.787, brightness: 0.254)  // Dark color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image(systemName: logo)
                                .font(.title2)
                                .frame(width: 30, height: 30)
                        )
                    )
                    .clipShape(Circle()) // Ensure the icon maintains its circular shape
                    .shadow(radius: 2) // Optional: add shadow to enhance visibility
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .bold()
                
                Text(value)
                    .bold()
                    .font(.title)
            }
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    self.isVisible = true
                }
            }
        }
    }
}

struct WeatherRow_Previews: PreviewProvider {
    static var previews: some View {
        WeatherRow(logo: "cloud.sun.fill", name: "Temperature", value: "22°C")
    }
}
