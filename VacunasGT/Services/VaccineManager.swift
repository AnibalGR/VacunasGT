//
//  VaccineManager.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

final class VaccineManager {
    static let shared = VaccineManager()
    
    private init() {}
    
    // Esquema Nacional de Vacunación de Guatemala (simplificado)
    func preloadOfficialScheme(modelContext: ModelContext) {
        // Verificar si ya existen vacunas para evitar duplicados
        let descriptor = FetchDescriptor<Vaccine>()
        let count = try? modelContext.fetchCount(descriptor)
        
        if count == 0 {
            let vacunas = [
                // Al Nacer
                Vaccine(nombre: "BCG", dosis: "Única", edadRecomendadaMeses: 0, descripcion: "Tuberculosis (Meninge y Miliar)"),
                Vaccine(nombre: "Hepatitis B", dosis: "Neonatal", edadRecomendadaMeses: 0, descripcion: "Previene la transmisión vertical de madre a hijo"),
                
                // 2 Meses
                Vaccine(nombre: "Polio", dosis: "1ra Dosis", edadRecomendadaMeses: 2, descripcion: "IPV (Inyectada)"),
                Vaccine(nombre: "Pentavalente", dosis: "1ra Dosis", edadRecomendadaMeses: 2, descripcion: "Difteria, Tétanos, Tosferina, HepB, H. Influenzae b"),
                Vaccine(nombre: "Neumococo", dosis: "1ra Dosis", edadRecomendadaMeses: 2, descripcion: "Neumonía y Meningitis"),
                Vaccine(nombre: "Rotavirus", dosis: "1ra Dosis", edadRecomendadaMeses: 2, descripcion: "Diarreas severas"),
                
                // 4 Meses
                Vaccine(nombre: "Polio", dosis: "2da Dosis", edadRecomendadaMeses: 4, descripcion: "IPV"),
                Vaccine(nombre: "Pentavalente", dosis: "2da Dosis", edadRecomendadaMeses: 4, descripcion: ""),
                Vaccine(nombre: "Neumococo", dosis: "2da Dosis", edadRecomendadaMeses: 4, descripcion: ""),
                Vaccine(nombre: "Rotavirus", dosis: "2da Dosis", edadRecomendadaMeses: 4, descripcion: ""),
                
                // 6 Meses
                Vaccine(nombre: "Polio", dosis: "3ra Dosis", edadRecomendadaMeses: 6, descripcion: "OPV (Oral)"),
                Vaccine(nombre: "Pentavalente", dosis: "3ra Dosis", edadRecomendadaMeses: 6, descripcion: ""),
                
                // 12 Meses (1 Año)
                Vaccine(nombre: "SPR", dosis: "1ra Dosis", edadRecomendadaMeses: 12, descripcion: "Sarampión, Paperas y Rubéola"),
                Vaccine(nombre: "Neumococo", dosis: "Refuerzo", edadRecomendadaMeses: 12, descripcion: ""),
                
                // 18 Meses (1 año y medio)
                Vaccine(nombre: "SPR", dosis: "2da Dosis", edadRecomendadaMeses: 18, descripcion: ""),
                Vaccine(nombre: "Polio", dosis: "1er Refuerzo", edadRecomendadaMeses: 18, descripcion: "OPV"),
                Vaccine(nombre: "DPT", dosis: "1er Refuerzo", edadRecomendadaMeses: 18, descripcion: "Difteria, Tétanos y Tosferina"),
                
                // 4 Años
                Vaccine(nombre: "Polio", dosis: "2do Refuerzo", edadRecomendadaMeses: 48, descripcion: "OPV"),
                Vaccine(nombre: "DPT", dosis: "2do Refuerzo", edadRecomendadaMeses: 48, descripcion: "")
            ]
            
            for vacuna in vacunas {
                modelContext.insert(vacuna)
            }
            
            try? modelContext.save()
            print("Esquema de vacunas precargado exitosamente.")
        }
    }
    
    // Calcula la fecha proyectada ideal para una vacuna basada en la fecha de nacimiento
    func calculateProjectedDate(birthDate: Date, months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: birthDate) ?? birthDate
    }
}
