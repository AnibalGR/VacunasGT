import Foundation
import SwiftData

final class MilestoneManager {
    static let shared = MilestoneManager()

    private init() {}

    /// Sincroniza el catálogo de hitos desde el servidor.
    /// Reemplaza todos los registros locales con los del API.
    func syncFromServer(modelContext: ModelContext) async {
        do {
            let request = try NetworkManager.shared.createRequest(
                endpoint: "/milestones",
                method: "GET"
            )

            let response = try await NetworkManager.shared.fetch(
                request: request,
                responseType: APIResponse<[MilestoneDTO]>.self
            )

            // Borrar catálogo local viejo
            try modelContext.delete(model: Milestone.self)

            // Insertar el nuevo catálogo del servidor
            for dto in response.data {
                let milestone = Milestone(
                    id: dto.id,
                    name: dto.name,
                    category: dto.category,
                    expectedMonthMin: dto.expected_month_min,
                    expectedMonthMax: dto.expected_month_max,
                    details: dto.description
                )
                modelContext.insert(milestone)
            }
            
            try modelContext.save()
            print("✅ Catálogo de hitos sincronizado: \(response.data.count) hitos.")

        } catch {
            print("❌ Error sincronizando hitos: \(error)")
            // Si falla la red, mantenemos el catálogo local existente
        }
    }
}
