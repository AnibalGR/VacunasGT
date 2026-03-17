//
//  VaccineManager.swift
//  VacunasGT
//

import Foundation
import SwiftData

// MARK: - DTO para la respuesta del API

fileprivate struct VaccineCatalogAPIResponse: Decodable {
    let data: [VaccineAPIDTO]
}

fileprivate struct VaccineAPIDTO: Decodable {
    let id: String
    let name: String
    let doseNumber: Int
    let recommendedAgeMonths: Int
    let sector: String
    let description: String?
    let isMandatory: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case doseNumber = "dose_number"
        case recommendedAgeMonths = "recommended_age_months"
        case sector
        case description
        case isMandatory = "is_mandatory"
    }
}

// MARK: - Manager

final class VaccineManager {
    static let shared = VaccineManager()

    private init() {}

    /// Sincroniza el catálogo de vacunas desde el servidor.
    /// Reemplaza todos los registros locales con los del API.
    /// Llamar después del login o al abrir la app con sesión activa.
    func syncFromServer(modelContext: ModelContext) async {
        do {
            let request = try NetworkManager.shared.createRequest(
                endpoint: "/vaccines",
                method: "GET"
            )

            let response = try await NetworkManager.shared.fetch(
                request: request,
                responseType: VaccineCatalogAPIResponse.self
            )

            // Borrar catálogo local viejo
            try modelContext.delete(model: Vaccine.self)

            // Insertar el nuevo catálogo del servidor
            for dto in response.data {
                let vaccine = Vaccine(
                    serverId: dto.id,
                    nombre: dto.name,
                    dosis: "Dosis \(dto.doseNumber)",
                    edadRecomendadaMeses: dto.recommendedAgeMonths,
                    descripcion: dto.description ?? "",
                    isPrivate: dto.sector == "private",
                    isMandatory: dto.isMandatory
                )
                modelContext.insert(vaccine)
            }

            try modelContext.save()
            print("✅ Catálogo de vacunas sincronizado: \(response.data.count) vacunas.")
        } catch {
            print("⚠️ No se pudo sincronizar el catálogo de vacunas: \(error). Se usarán datos locales si existen.")
        }
    }

    /// Calcula la fecha proyectada ideal para una vacuna según la fecha de nacimiento.
    func calculateProjectedDate(birthDate: Date, months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: birthDate) ?? birthDate
    }
}
