//
//  VaccineManager.swift
//  VacunasGT
//

import Foundation
import SwiftData

// MARK: - DTO para la respuesta del API

private struct VaccineCatalogResponse: Decodable {
    let data: [VaccineDTO]
}

private struct VaccineDTO: Decodable {
    let id: String
    let name: String
    let dose_number: Int
    let recommended_age_months: Int
    let sector: String
    let description: String?
    let is_mandatory: Bool
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
                responseType: VaccineCatalogResponse.self
            )

            // Borrar catálogo local viejo
            try modelContext.delete(model: Vaccine.self)

            // Insertar el nuevo catálogo del servidor
            for dto in response.data {
                let vaccine = Vaccine(
                    serverId: dto.id,
                    nombre: dto.name,
                    dosis: "Dosis \(dto.dose_number)",
                    edadRecomendadaMeses: dto.recommended_age_months,
                    descripcion: dto.description ?? "",
                    isPrivate: dto.sector == "private",
                    isMandatory: dto.is_mandatory
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
