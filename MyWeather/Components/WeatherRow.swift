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
            Image(systemName: logo)
                .font(.title2)
                .frame(width: 20, height: 20)
                .padding()
                .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                .cornerRadius(50)
                .opacity(isVisible ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.isVisible = true
                    }
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
