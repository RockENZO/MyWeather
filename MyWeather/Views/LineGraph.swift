import SwiftUI

struct LineGraph: View {
    var dataPoints: [(time: String, temp: Double)]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let maxTemp = dataPoints.map { $0.temp }.max() ?? 1
            let minTemp = dataPoints.map { $0.temp }.min() ?? 0
            let tempRange = maxTemp - minTemp
            
            Path { path in
                for (index, point) in dataPoints.enumerated() {
                    let xPosition = width * CGFloat(index) / CGFloat(dataPoints.count - 1)
                    let yPosition = height * (1 - CGFloat((point.temp - minTemp) / tempRange))
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}