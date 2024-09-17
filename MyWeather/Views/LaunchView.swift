//
//  LaunchView.swift
//  MyWeather
//
//  Created by Rock on 16/9/2024.
//

import SwiftUI

struct LaunchView: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.0
    @State private var rotationX: Double = -30
    @State private var offsetY: CGFloat = -50
    @State private var color: Color = .blue // Initial color
    @State private var isAnimating = true // To control color animation

    let colors: [Color] = [.blue, .red, .purple, .green, .orange] // Array of colors

    var body: some View {
        VStack {
            // Weather icon with 3D rotation, bounce, and color change
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 100))
                .foregroundColor(color)
                .rotation3DEffect(.degrees(rotationX), axis: (x: 1.0, y: 0.0, z: 0.0))
                .scaleEffect(scale)
                .opacity(opacity)
                .offset(y: offsetY)
                .onAppear {
                    // Animation for scaling, opacity, bounce, and color change
                    withAnimation(.easeInOut(duration: 1.0)) { // Increased duration
                        self.scale = 1.05
                        self.opacity = 1.0
                        self.rotationX = 0
                    }
                    withAnimation(.easeInOut(duration: 1.0).delay(0.8)) { // Increased duration and delay
                        self.offsetY = 0
                    }
                    // Change color every 0.5 seconds and stop after 5 seconds
                    let colorChangeInterval: TimeInterval = 0.5
                    let totalColorChangeDuration: TimeInterval = 5.0
                    Timer.scheduledTimer(withTimeInterval: colorChangeInterval, repeats: true) { timer in
                        if self.isAnimating {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.color = colors.randomElement() ?? .blue
                            }
                        } else {
                            timer.invalidate()
                        }
                    }
                    // Stop color change after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + totalColorChangeDuration) {
                        self.isAnimating = false
                    }
                }
            
            // App name with smoother scaling and color change
            Text("MyWeather")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Applying gradient background
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: 0.656, saturation: 0.787, brightness: 0.954), // Lightened shade
                    Color(hue: 0.656, saturation: 0.787, brightness: 0.054)  // Darkened shade
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
