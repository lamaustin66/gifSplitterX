//
// PlaybackSetting.swift
//
enum SortKey {
    case creationDate
    case modificationDate
}

struct PlaybackSetting {
    var sortKey: SortKey
    var isAscending: Bool
    var animationPreviewIntegrityValue: GifLevelOfIntegrity
    
    init() {
        sortKey = .creationDate
        isAscending = false
        animationPreviewIntegrityValue = .default
    }
}
