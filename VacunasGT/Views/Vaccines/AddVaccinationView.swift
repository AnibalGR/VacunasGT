import SwiftUI
import SwiftData

struct AddVaccinationView: View {
    let childUUID: String
    /// IDs del catálogo (Int) de vacunas ya aplicadas al niño
    let appliedVaccineCatalogIds: Set<Int>

    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) var dismiss

    // Catálogo completo sincronizado con el servidor
    @Query(sort: \Vaccine.edadRecomendadaMeses) private var allVaccines: [Vaccine]

    // Paso 1: nombre de vacuna seleccionado
    @State private var selectedVaccineName: String? = nil
    // Paso 2: dosis seleccionada
    @State private var selectedVaccine: Vaccine? = nil

    @State private var applicationDate: Date = Date()
    @State private var healthFacility: String = ""
    @State private var notes: String = ""

    // MARK: - Computed helpers

    /// Nombres únicos de vacunas, en orden de edad recomendada
    private var uniqueVaccineNames: [String] {
        var seen = Set<String>()
        return allVaccines.compactMap { v in
            guard !seen.contains(v.nombre) else { return nil }
            seen.insert(v.nombre)
            return v.nombre
        }
    }

    /// Dosis disponibles para el nombre seleccionado, excluyendo las ya aplicadas
    private var availableDoses: [Vaccine] {
        guard let name = selectedVaccineName else { return [] }
        return allVaccines.filter { v in
            v.nombre == name && !appliedVaccineCatalogIds.contains(Int(v.serverId) ?? -1)
        }
    }

    private var canSubmit: Bool {
        selectedVaccine != nil && !viewModel.isLoading
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Registrar Aplicación de Vacuna")
                                .font(.headline)
                                .foregroundColor(.brandNavy)

                            // ── Paso 1: Nombre de vacuna ──────────────────────
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Vacuna", systemImage: "syringe")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)

                                if allVaccines.isEmpty {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text("Cargando catálogo…")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                } else {
                                    Picker("Vacuna", selection: $selectedVaccineName) {
                                        Text("Seleccionar vacuna…").tag(Optional<String>.none)
                                        ForEach(uniqueVaccineNames, id: \.self) { name in
                                            Text(name).tag(Optional(name))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                                    .onChange(of: selectedVaccineName) { _, _ in
                                        // Resetear dosis al cambiar de vacuna
                                        selectedVaccine = nil
                                    }
                                }
                            }

                            // ── Paso 2: Dosis disponibles ─────────────────────
                            if let name = selectedVaccineName {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Dosis disponible", systemImage: "number.circle")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.secondary)

                                    if availableDoses.isEmpty {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.green)
                                            Text("Todas las dosis de \(name) ya fueron aplicadas.")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                    } else {
                                        Picker("Dosis", selection: $selectedVaccine) {
                                            Text("Seleccionar dosis…").tag(Optional<Vaccine>.none)
                                            ForEach(availableDoses) { dose in
                                                Text(dose.dosis).tag(Optional(dose))
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .tint(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(.easeInOut(duration: 0.2), value: selectedVaccineName)
                            }

                            // ── Fecha de Aplicación ───────────────────────────
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Fecha de Aplicación", systemImage: "calendar")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)

                                DatePicker("Fecha de Aplicación", selection: $applicationDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.graphical)
                                    .tint(.brandNavy)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                            }

                            // ── Centro de Salud y Notas ───────────────────────
                            CustomTextField(text: $healthFacility, placeholder: "Centro de Salud / Hospital", icon: "cross.case.fill")
                            CustomTextField(text: $notes, placeholder: "Notas adicionales", icon: "note.text")
                        }
                        .padding(20)
                    }

                    // ── Botón Confirmar ───────────────────────────────────
                    Button(action: submit) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Confirmar Registro")
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(!canSubmit)
                    .padding()
                }
            }
            .navigationTitle("Nueva Vacuna")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                        .foregroundColor(.brandNavy)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Actions

    private func submit() {
        guard let vaccine = selectedVaccine,
              let vaccineServerId = Int(vaccine.serverId) else { return }
        Task {
            let success = await viewModel.addVaccination(
                childUUID: childUUID,
                vaccineId: vaccineServerId,
                date: applicationDate,
                facility: healthFacility.isEmpty ? nil : healthFacility,
                notes: notes.isEmpty ? nil : notes
            )
            if success { dismiss() }
        }
    }
}
