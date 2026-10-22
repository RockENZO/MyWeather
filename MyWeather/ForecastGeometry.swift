import Foundation

/// Finite, normalized points shared by the path and its markers.
enum ForecastGeometry {
    struct Point {
        let time: String
        let temperature: Double
        let x: Double
        let y: Double
    }

    static func points(_ input: [(time: String, temp: Double)]) -> [Point] {
        let valid = input.filter { $0.temp.isFinite }
        let smoothed = valid.indices.map { index -> (time: String, temp: Double) in
            guard valid.count >= 3 else { return valid[index] }
            let start = max(0, index - 1)
            let end = min(valid.count - 1, index + 1)
            let count = Double(end - start + 1)
            let scale = max(valid[start...end].map { abs($0.temp) }.max() ?? 1, 1)
            let normalized = valid[start...end].reduce(0.0) { $0 + ($1.temp / scale) / count }
            let average = min(1, max(-1, normalized)) * scale
            return (valid[index].time, average)
        }
        guard let low = smoothed.map(\.temp).min(),
              let high = smoothed.map(\.temp).max() else { return [] }
        let scale = max(abs(low), abs(high), 1)
        let minimum = low / scale
        let range = high / scale - minimum
        return smoothed.enumerated().map { index, point in
            let y = range > 0 ? 1 - (point.temp / scale - minimum) / range : 0.5
            return Point(time: point.time, temperature: point.temp,
                         x: smoothed.count > 1 ? Double(index) / Double(smoothed.count - 1) : 0.5,
                         y: min(1, max(0, y)))
        }
    }
}
