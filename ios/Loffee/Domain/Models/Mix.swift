import Foundation

struct Mix: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    let createdAt: Date
    var updatedAt: Date
    var items: [MixItem]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date,
        updatedAt: Date,
        items: [MixItem]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
    }
}

struct MixItem: Codable, Equatable {
    let soundID: String
    var volume: Float
}