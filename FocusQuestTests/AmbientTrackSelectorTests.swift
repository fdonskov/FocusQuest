import Testing
@testable import FocusQuest

struct AmbientTrackSelectorTests {
    @Test func poolPrefersPresetThenLocationThenDefault() {
        #expect(AmbientTrackSelector.pool(perPreset: ["p"], perLocation: ["l"], perDefault: ["d"]) == ["p"])
        #expect(AmbientTrackSelector.pool(perPreset: [], perLocation: ["l"], perDefault: ["d"]) == ["l"])
        #expect(AmbientTrackSelector.pool(perPreset: [], perLocation: [], perDefault: ["d"]) == ["d"])
        #expect(AmbientTrackSelector.pool(perPreset: [String](), perLocation: [], perDefault: []) == [])
    }

    @Test func nextIndexRoundRobins() {
        #expect(AmbientTrackSelector.nextIndex(current: nil, count: 3) == 0)
        #expect(AmbientTrackSelector.nextIndex(current: 0, count: 3) == 1)
        #expect(AmbientTrackSelector.nextIndex(current: 1, count: 3) == 2)
        #expect(AmbientTrackSelector.nextIndex(current: 2, count: 3) == 0)
    }

    @Test func nextIndexHandlesSingleAndEmptyPools() {
        #expect(AmbientTrackSelector.nextIndex(current: 0, count: 1) == 0)
        #expect(AmbientTrackSelector.nextIndex(current: nil, count: 0) == 0)
        #expect(AmbientTrackSelector.nextIndex(current: 5, count: 0) == 0)
    }
}
