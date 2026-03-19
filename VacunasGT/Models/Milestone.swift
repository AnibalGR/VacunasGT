import Foundation
import SwiftData

/// Representa un hito del desarrollo en el catálogo local
@Model
final class Milestone {
    @Attribute(.unique) var id: Int
    var name: String
    var category: String
    var expectedMonthMin: Int
    var expectedMonthMax: Int
    var details: String? // 'description' en la API
    
    init(id: Int, name: String, category: String, expectedMonthMin: Int, expectedMonthMax: Int, details: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.expectedMonthMin = expectedMonthMin
        self.expectedMonthMax = expectedMonthMax
        self.details = details
    }
}
