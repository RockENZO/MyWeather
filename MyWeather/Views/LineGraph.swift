//
//  LineGraph.swift
//  MyWeather
//
//  Created by Rock on 9/21/2024.
//

import SwiftUI

struct LineGraph: View {
    var dataPoints: [(time: String, temp: Double)]
    
    var body: some View {
        VStack(alignment: .center) {
            // Add "Forecast" text above the LineGraph
            Text("Forecast")
                .font(.title2)
                .bold()
                .foregroundColor(.glassText)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let points = ForecastGeometry.points(dataPoints)

                if points.isEmpty {
                    Text("Hourly forecast unavailable")
                        .foregroundColor(.glassSecondaryText)
                        .frame(width: width, height: height)
                } else {

                    HStack(spacing: 0) {
                        ZStack {
                            Path { path in
                                for (index, point) in points.enumerated() {
                                    let xPosition = width * point.x
                                    let yPosition = height * point.y
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                                    } else {
                                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                                    }
                                }
                            }
                            .stroke(Color.blue, lineWidth: 4) // Increased line width from 2 to 4
                            
                            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                                let xPosition = width * point.x
                                let yPosition = height * point.y
                                
                                VStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.8))
                                        .frame(width: 10, height: 10) // Increased point size from 8 to 10
                                        .position(x: xPosition, y: yPosition)
                                    
                                    if index % 5 == 0 {
                                        Text("\(point.temperature.formatted(.number.precision(.fractionLength(0))))°")
                                            .font(.system(size: 16))
                                            .bold()
                                            .foregroundColor(.glassText)
                                            .position(x: xPosition, y: yPosition - 39)
                                    }
                                    
                                    Text(point.time)
                                        .font(.caption)
                                        .foregroundColor(.glassSecondaryText)
                                        .position(x: xPosition, y: height - 10)
                                }
                            }
                        }
                        .frame(width: width, height: height)
                        .scaleEffect(0.8) // Scale the graph to be smaller
                    }
                    .frame(width: width)
                }
            }
        }
        .frame(height: 150)
        .cornerRadius(20)
        .glassBackground(tint: .primary, opacity: 0)
    }
    

}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        LineGraph(dataPoints: [
            (time: "12:00", temp: 20.0),
            (time: "13:00", temp: 22.0),
            (time: "14:00", temp: 24.0),
            (time: "15:00", temp: 23.0),
            (time: "16:00", temp: 21.0),
            (time: "17:00", temp: 19.0)
        ])
        .frame(height: 200)
        .padding()
        .background(Color.gray)
        .cornerRadius(20)
        .padding()
    }
}
