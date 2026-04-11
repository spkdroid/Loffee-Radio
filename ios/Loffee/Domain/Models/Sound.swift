import Foundation

struct Sound: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let audioBaseName: String
    let category: String
    let normalArtworkName: String
    let selectedArtworkName: String
    var volume: Float
    var isSelected: Bool

    init(
        id: String,
        name: String,
        audioBaseName: String,
        category: String,
        normalArtworkName: String,
        selectedArtworkName: String,
        volume: Float = 0.6,
        isSelected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.audioBaseName = audioBaseName
        self.category = category
        self.normalArtworkName = normalArtworkName
        self.selectedArtworkName = selectedArtworkName
        self.volume = volume
        self.isSelected = isSelected
    }
}