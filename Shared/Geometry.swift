import SwiftUI

struct Geometry {
    struct UnitCircle {
        static func point(divisions: Int, point: Int) -> CGPoint {
            let angle = Angle.degrees(Double((360 / divisions) * point))
            return CGPoint(x: CGFloat(cos(angle.radians)),
                           y: CGFloat(sin(angle.radians)))
        }
        
        static func allPoints(divisions: Int) -> [CGPoint] {
            (0..<divisions).map { point(divisions: divisions, point: $0) }
        }
    }
    
    struct Circle {
        static func allPoints(radius: CGFloat, center: CGPoint, divisons: Int) -> [CGPoint] {
            Geometry.UnitCircle.allPoints(divisions: divisons)
                .map { $0.scaled(radius) }
                .map { $0.offset(center.x, center.y) }
        }
    }
    
    static func slope(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        (b.y - a.y) / (b.x - a.x)
    }
    
    static func bounded(_ value: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        guard value > range.lowerBound else { return range.lowerBound }
        guard value < range.upperBound else { return range.upperBound }
        return value
    }
    
    struct PointPair {
        let start: CGPoint
        let end: CGPoint
        
        init(_ start: CGPoint, _ end: CGPoint) {
            self.start = start
            self.end = end
        }
        
        var flipped: PointPair {
            PointPair(end, start)
        }
        
        static let zero = PointPair(.zero, .zero)
    }
    
    // Assumes lines have an intersection
    static func intersection(between a: PointPair, and b: PointPair) -> CGPoint {
        /*
         Given the form:
         y1 = m1*x1 + b1 defined by a to b
         y2 = m2*x2 + b2 defined by c to d
         Intersection can be calculated:
         x = (b1 - b2) / (m2 - m1)
         y = ((m1 * (b1 - b2)) / (m2 - m1)) + b1
         */
        
        let m1 = slope(a.start, a.end)
        let m2 = slope(b.start, b.end)
        
        assert((m2 - m1) != .infinity, "intersection is not possible")
        assert((m2 - m1) != 0, "intersection is not possible")
        
        let b1 = a.start.y - (m1 * a.start.x)
        let b2 = b.start.y - (m2 * b.start.x)
        
        let x = (b1 - b2) / (m2 - m1)
        let y = ((m1 * (b1 - b2)) / (m2 - m1)) + b1
        
        return CGPoint(x: x, y: y)
    }
        
    static func boundedPointsForLine(between a: CGPoint, and b: CGPoint, in rect: CGRect) -> PointPair {
        // Vertical Line
        guard a.x != b.x else {
            return PointPair(CGPoint(x: a.x, y: rect.minY), CGPoint(x: b.x, y: rect.maxY))
        }
        
        // Horizontal Line
        guard a.y != b.y else {
            return PointPair(CGPoint(x: rect.minX, y: a.y), CGPoint(x: rect.maxX, y: b.y))
        }
        
        let m = slope(a, b)
        let b = a.y - (m * a.x)
        
        let dx = rect.minX...rect.maxX
        let dy = rect.minY...rect.maxY
        
        
        let y1: CGFloat = bounded(m * rect.minX + b, range: dy)
        let y2: CGFloat = bounded(m * rect.maxX + b, range: dy)
        
        let x1: CGFloat
        let x2: CGFloat
        
        if m > 0 {
            x1 = bounded((rect.minY - b) / m, range: dx)
            x2 = bounded((rect.maxY - b) / m, range: dx)
        } else {
            x1 = bounded((rect.maxY - b) / m, range: dx)
            x2 = bounded((rect.minY - b) / m, range: dx)
        }
        
        return PointPair(CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2))
    }
    
    static func boundedPathForLine(between a: CGPoint, and b: CGPoint, in rect: CGRect) -> Path {
        let points = boundedPointsForLine(between: a, and: b, in: rect)
        return Path {
            $0.move(to: points.start)
            $0.addLine(to: points.end)
        }
    }
    
    enum RectDivision {
        case topHalf
        case bottomHalf
        case leftHalf
        case rightHalf
    }
    
    static func divide(_ rect: CGRect, by division: RectDivision) -> CGRect {
        switch division {
        case .topHalf:
            return CGRect(x: rect.minX,
                          y: rect.minY,
                          width: rect.width,
                          height: rect.height / 2)
        case .bottomHalf:
            return CGRect(x: rect.minX,
                          y: rect.midY,
                          width: rect.width,
                          height: rect.height / 2)
        case .leftHalf:
            return CGRect(x: rect.minX,
                          y: rect.minY,
                          width: rect.width / 2,
                          height: rect.height)
        case .rightHalf:
            return CGRect(x: rect.midX,
                          y: rect.minY,
                          width: rect.width / 2,
                          height: rect.height)
        }
    }
}

extension CGPoint {
    func scaled(_ s: CGFloat) -> CGPoint {
        CGPoint(x: s * x, y: s * y)
    }
    
    func offset(_ d: CGFloat) -> CGPoint {
        CGPoint(x: x + d, y: x + d)
    }
    
    func offset(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
}

extension CGRect {
    func divided(by division: Geometry.RectDivision) -> CGRect {
        return Geometry.divide(self, by: division)
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
