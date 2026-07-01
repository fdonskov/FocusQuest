import Foundation

// Pure track-selection logic for ambient audio, kept separate from AVFoundation/Bundle
// so the priority and round-robin rules are unit-testable.
enum AmbientTrackSelector {
    // Priority: per-preset pool, else per-location pool, else the default pool.
    static func pool<Element>(perPreset: [Element], perLocation: [Element], perDefault: [Element]) -> [Element] {
        if !perPreset.isEmpty { return perPreset }
        if !perLocation.isEmpty { return perLocation }
        return perDefault
    }

    // Next index in a round-robin; starts at 0, wraps, safe for empty pools.
    static func nextIndex(current: Int?, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return current.map { ($0 + 1) % count } ?? 0
    }
}
