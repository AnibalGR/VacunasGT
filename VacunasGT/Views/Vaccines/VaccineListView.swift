//
//  VaccineListView.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import SwiftUI
import SwiftData

struct VaccineListView: View {
    let child: Child
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Vaccine.edadRecomendadaMeses) private var allVaccines: [Vaccine]
    
    // Filtros locales
    var pendingVaccines: [Vaccine] {
        allVaccines.filter { vaccine in
            !child.registrosVacunacion.contains { $0.vaccine?.nombre == vaccine.nombre && $0.vaccine?.dosis == vaccine.dosis }
        }
    }
    
    var completedRecords: [VaccinationRecord] {
        child.registrosVacunacion.sorted {
            ($0.vaccine?.edadRecomendadaMeses ?? 0) < ($1.vaccine?.edadRecomendadaMeses ?? 0)
        }
    }
    
    var body: some View {
        List {
            if !pendingVaccines.isEmpty {
                Section(header: Text("Pendientes")) {
                    ForEach(pendingVaccines) { vaccine in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vaccine.nombre)
                                    .font(.headline)
                                Text(vaccine.dosis)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                if let date = calculateDate(for: vaccine) {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(date < Date() ? .red : .blue)
                                }
                                Button("Registrar") {
                                    registerVaccine(vaccine)
                                }
                                .buttonStyle(.bordered)
                                .font(.caption)
                            }
                        }
                    }
                }
            }
            
            if !completedRecords.isEmpty {
                Section(header: Text("Completadas")) {
                    ForEach(completedRecords) { record in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text(record.vaccine?.nombre ?? "Desconocida")
                                    .font(.headline)
                                Text(record.vaccine?.dosis ?? "")
                                    .font(.caption)
                            }
                            Spacer()
                            if let date = record.fechaAplicacion {
                                Text(date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions {
                            Button("Eliminar", role: .destructive) {
                                deleteRecord(record)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Vacunas de \(child.nombre)")
    }
    
    private func calculateDate(for vaccine: Vaccine) -> Date? {
        // Usa el servicio singleton para calcular
        return VaccineManager.shared.calculateProjectedDate(birthDate: child.fechaNacimiento, months: vaccine.edadRecomendadaMeses)
    }
    
    private func registerVaccine(_ vaccine: Vaccine) {
        let newRecord = VaccinationRecord(fechaAplicacion: Date(), isCompleted: true, child: child, vaccine: vaccine)
        child.registrosVacunacion.append(newRecord)
        // SwiftData autosave
    }
    
    private func deleteRecord(_ record: VaccinationRecord) {
        modelContext.delete(record)
        // Al ser relación Cascade, se elimina del child automáticamente, pero aquí lo borramos del contexto
        // Ojo: Si borramos del contexto, la relación se actualiza.
    }
}
