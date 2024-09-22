//
//  LineGraph.swift
//  MyWeather
//
//  Created by Rock on 9/21/2024.
//



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
            // Add "Hourly Forecast" text above the LineGraph
            Text("Hourly Forecast")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let maxTemp = dataPoints.map { $0.temp }.max() ?? 1
                let minTemp = dataPoints.map { $0.temp }.min() ?? 0
                let tempRange = maxTemp - minTemp
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ZStack {
                            Path { path in
                                for (index, point) in dataPoints.enumerated() {
                                    let xPosition = width * CGFloat(index) / CGFloat(dataPoints.count - 1)
                                    let normalizedTemp = (point.temp - minTemp) / tempRange
                                    let yPosition = height * (1 - CGFloat(normalizedTemp))
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                                    } else {
                                        let previousPoint = dataPoints[index - 1]
                                        let previousXPosition = width * CGFloat(index - 1) / CGFloat(dataPoints.count - 1)
                                        let previousNormalizedTemp = (previousPoint.temp - minTemp) / tempRange
                                        let previousYPosition = height * (1 - CGFloat(previousNormalizedTemp))
                                        
                                        let controlPoint1 = CGPoint(x: (previousXPosition + xPosition) / 2, y: previousYPosition)
                                        let controlPoint2 = CGPoint(x: (previousXPosition + xPosition) / 2, y: yPosition)
                                        
                                        path.addCurve(to: CGPoint(x: xPosition, y: yPosition), control1: controlPoint1, control2: controlPoint2)
                                    }
                                }
                            }
                            .stroke(Color.blue, lineWidth: 4) // Increased line width from 2 to 4
                            
                            ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, point in
                                let xPosition = width * CGFloat(index) / CGFloat(dataPoints.count - 1)
                                let normalizedTemp = (point.temp - minTemp) / tempRange
                                let yPosition = height * (1 - CGFloat(normalizedTemp))
                                
                                VStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 10, height: 10) // Increased point size from 8 to 10
                                        .position(x: xPosition, y: yPosition)
                                    
                                    if index % 5 == 0 {
                                        Text("\(point.temp.roundDouble())°")
                                            .font(.system(size: 16))
                                            .bold()
                                            .foregroundColor(.white)
                                            .position(x: xPosition, y: yPosition - 39)
                                    }
                                    
                                    Text(point.time)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .position(x: xPosition, y: height - 10)
                                }
                            }
                        }
                        .frame(width: width, height: height)
                        .scaleEffect(0.8) // Scale the graph to be smaller
                    }
                    .frame(width: width * CGFloat(dataPoints.count - 1) / CGFloat(dataPoints.count - 1))
                }
            }
            .frame(height: 150)
            .cornerRadius(20)
        }
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
