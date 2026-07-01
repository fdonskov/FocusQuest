import SwiftUI

struct LocationAmbianceView: View {
    let locationID: String

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                draw(in: context, size: size, t: t)
            }
        }
        .allowsHitTesting(false)
    }

    private func draw(in context: GraphicsContext, size: CGSize, t: Double) {
        switch locationID {
        case "meadow":
            fireflies(context, size, t, count: 22)
            birds(context, size, t, count: 2, color: Color.black.opacity(0.45), speed: 38)
        case "forest":
            leaves(context, size, t, count: 16, color: Color(hue: 0.32, saturation: 0.5, brightness: 0.7))
            birds(context, size, t, count: 2, color: Color.black.opacity(0.4), speed: 34)
        case "caves":
            embers(context, size, t, count: 26, color: Color(hue: 0.08, saturation: 0.85, brightness: 1))
        case "mountains":
            snow(context, size, t, count: 70)
            birds(context, size, t, count: 1, color: Color.black.opacity(0.35), speed: 26)
        case "castle":
            embers(context, size, t, count: 16, color: Color(hue: 0.09, saturation: 0.8, brightness: 0.95))
            birds(context, size, t, count: 3, color: Color.black.opacity(0.6), speed: 70, flap: 10)
        case "voidgate":
            voidEnergy(context, size, t, count: 30)
        default:
            fireflies(context, size, t, count: 18)
        }
    }

    // Deterministic pseudo-random in [0,1) from particle index + salt.
    private func rnd(_ i: Int, _ salt: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: (i &* 2654435761) ^ (salt &* 40503) ^ 0x9E3779B9)
        x = x &* 0x2545F4914F6CDD1D
        x ^= x >> 29
        return Double((x >> 33) & 0xFFFFFF) / Double(0x1000000)
    }

    private func fireflies(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, count: Int) {
        let color = Color(hue: 0.24, saturation: 0.7, brightness: 1)
        for i in 0..<count {
            let baseX = rnd(i, 1) * size.width
            let baseY = rnd(i, 2) * size.height
            let x = baseX + sin(t * 0.4 + rnd(i, 3) * 6.28) * 22
            let y = baseY + cos(t * 0.32 + rnd(i, 4) * 6.28) * 18
            let pulse = 0.25 + 0.75 * abs(sin(t * 1.4 + rnd(i, 5) * 6.28))
            let r = 1.6 + rnd(i, 6) * 1.8
            ctx.fill(Path(ellipseIn: CGRect(x: x - r * 2, y: y - r * 2, width: r * 4, height: r * 4)),
                     with: .color(color.opacity(0.12 * pulse)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(color.opacity(0.9 * pulse)))
        }
    }

    private func snow(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, count: Int) {
        for i in 0..<count {
            let speed = 22 + rnd(i, 2) * 34
            let x = rnd(i, 1) * size.width + sin(t * 0.6 + rnd(i, 4) * 6.28) * 12
            let y = (rnd(i, 3) * size.height + t * speed).truncatingRemainder(dividingBy: size.height)
            let r = 1.3 + rnd(i, 5) * 2.2
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(.white.opacity(0.6 + rnd(i, 6) * 0.3)))
        }
    }

    private func embers(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, count: Int, color: Color) {
        for i in 0..<count {
            let speed = 24 + rnd(i, 2) * 40
            let x = rnd(i, 1) * size.width + sin(t * 0.9 + rnd(i, 4) * 6.28) * 16
            let raw = (rnd(i, 3) * size.height - t * speed).truncatingRemainder(dividingBy: size.height)
            let y = raw < 0 ? raw + size.height : raw
            let fade = y / size.height
            let r = 1.0 + rnd(i, 5) * 1.8
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(color.opacity(0.85 * fade)))
        }
    }

    private func leaves(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, count: Int, color: Color) {
        for i in 0..<count {
            let speed = 18 + rnd(i, 2) * 26
            let x = rnd(i, 1) * size.width + sin(t * 0.8 + rnd(i, 4) * 6.28) * 26
            let y = (rnd(i, 3) * size.height + t * speed).truncatingRemainder(dividingBy: size.height)
            var layer = ctx
            layer.translateBy(x: x, y: y)
            layer.rotate(by: .radians(t * (0.8 + rnd(i, 5)) + rnd(i, 6) * 6.28))
            layer.fill(Path(ellipseIn: CGRect(x: -4, y: -2.5, width: 8, height: 5)),
                       with: .color(color.opacity(0.75)))
        }
    }

    private func voidEnergy(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, count: Int) {
        let center = CGPoint(x: size.width / 2, y: size.height * 0.42)
        for i in 0..<count {
            let radius = 40 + rnd(i, 1) * 230
            let speed = 0.15 + rnd(i, 2) * 0.4
            let angle = t * speed + rnd(i, 3) * 6.28
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius * 0.7
            let hue = 0.78 + rnd(i, 4) * 0.12
            let r = 1.2 + rnd(i, 5) * 2.2
            let pulse = 0.4 + 0.6 * abs(sin(t * 1.2 + rnd(i, 6) * 6.28))
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(Color(hue: hue, saturation: 0.8, brightness: 1).opacity(0.8 * pulse)))
        }
    }

    private func birds(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double,
                       count: Int, color: Color, speed: Double, flap: Double = 6) {
        let span = size.width + 120
        for i in 0..<count {
            let lane = 0.12 + rnd(i, 1) * 0.4
            let raw = (rnd(i, 2) * span + t * speed).truncatingRemainder(dividingBy: span)
            let x = raw - 60
            let y = size.height * lane + sin(t * 0.7 + rnd(i, 3) * 6.28) * 14
            let wing = sin(t * 5 + rnd(i, 4) * 6.28) * flap
            var path = Path()
            path.move(to: CGPoint(x: x - 9, y: y))
            path.addLine(to: CGPoint(x: x, y: y - wing))
            path.addLine(to: CGPoint(x: x + 9, y: y))
            ctx.stroke(path, with: .color(color), lineWidth: 2)
        }
    }
}
