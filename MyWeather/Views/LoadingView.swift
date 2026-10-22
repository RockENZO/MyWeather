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

    let gradientColors: [Color] = [.blue, .purple, .pink, .orange]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: 0.656, saturation: 0.787, brightness: 0.954), // Lightened shade
                    Color(hue: 0.656, saturation: 0.787, brightness: 0.054)  // Darkened shade
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .edgesIgnoringSafeArea(.all)
                .glassBackground(tint: .primary, opacity: 0.1)
                .animation(
                    Animation.linear(duration: 6).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
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
                    .foregroundColor(.glassText)
                    .bold()
            }
            .task {
                isAnimating = true
                defer { isAnimating = false }
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(nanoseconds: 500_000_000)
                    } catch {
                        return
                    }
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.5)) {
                        color = gradientColors.randomElement() ?? .blue
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
