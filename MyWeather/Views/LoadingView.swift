//
//  LoadingView.swift
//  MyWeather
//
//  Created by Rock on 15/9/2024.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var color: Color = .blue // Initial color
    @State private var isColorAnimating = true // To control color animation

    let colors: [Color] = [.blue, .red, .purple, .green, .orange] // Array of colors

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image(systemName: "cloud.sun.rain.fill") // SF Symbol for loading
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(color)
                    .scaleEffect(isAnimating ? 1.2 : 0.7)
                    .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Loading Weather Data...")
                    .font(.title)
                    .foregroundColor(color)
                    .bold()
                    .padding(.top, 20)
            }
            .onAppear {
                self.isAnimating = true
                
                // Change color every 0.5 seconds indefinitely
                let colorChangeInterval: TimeInterval = 0.5
                Timer.scheduledTimer(withTimeInterval: colorChangeInterval, repeats: true) { timer in
                    if self.isColorAnimating {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.color = colors.randomElement() ?? .blue
                        }
                    }
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
