import Foundation

@main struct ForecastChecks {
    static func main() {
        assert(ForecastGeometry.points([]).isEmpty)
        let single = ForecastGeometry.points([("12", 20)])
        assert(single.count == 1 && single[0].x == 0.5 && single[0].y == 0.5)
        let flat = ForecastGeometry.points([("12", 20), ("13", 20), ("14", 20)])
        assert(flat.allSatisfy { $0.y == 0.5 })
        for values: [Double] in [[0, 10], [-30, -10, -20], [.nan, 20, .infinity],
                                [.greatestFiniteMagnitude, -.greatestFiniteMagnitude],
                                [.greatestFiniteMagnitude, .greatestFiniteMagnitude, .greatestFiniteMagnitude]] {
            let result = ForecastGeometry.points(values.enumerated().map { (String($0.offset), $0.element) })
            assert(result.allSatisfy { $0.temperature.isFinite && $0.x.isFinite && $0.y.isFinite
                && (0...1).contains($0.x) && (0...1).contains($0.y) })
        }
        let rising = ForecastGeometry.points([("12", 0), ("13", 10)])
        assert(rising[0].x == 0 && rising[1].x == 1)
        assert(rising[0].y == 1 && rising[1].y == 0)
        print("Forecast geometry: empty, singleton, flat, invalid, extreme and normal cases passed")
    }
}
