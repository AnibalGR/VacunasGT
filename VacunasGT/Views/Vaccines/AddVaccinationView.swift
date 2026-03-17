import SwiftUI
import SwiftData

struct AddVaccinationView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) var dismiss

    // Lee el catálogo sincronizado con el servidor
    @Query(sort: \Vaccine.edadRecomendadaMeses) private var vaccines: [Vaccine]

    @State private var selectedVaccine: Vaccine? = nil
    @State private var applicationDate: Date = Date()
    @State private var healthFacility: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Registrar Aplicación de Vacuna")
                                .font(.headline)
                                .foregroundColor(.brandNavy)
                                .padding(.horizontal)

                            VStack(alignment: .leading) {
                                Text("Selecciona la Vacuna")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)

                                if vaccines.isEmpty {
                                    HStack {
                                        ProgressView()
                                        Text("Cargando catálogo…")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                } else {
                                    Picker("Vacuna", selection: $selectedVaccine) {
                                        Text("Seleccionar…").tag(Optional<Vaccine>.none)
                                        ForEach(vaccines) { vaccine in
                                            Text("\(vaccine.nombre) — \(vaccine.dosis)")
                                                .tag(Optional(vaccine))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.primary)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal)

                            VStack(alignment: .leading) {
                                Text("Fecha de Aplicación")
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
                            .padding(.horizontal)

                            CustomTextField(text: $healthFacility, placeholder: "Centro de Salud / Hospital", icon: "hospital.fill")
                                .padding(.horizontal)

                            CustomTextField(text: $notes, placeholder: "Notas adicionales", icon: "note.text")
                                .padding(.horizontal)
                        }
                    }

                    Button(action: {
                        Task {
                            guard let vaccine = selectedVaccine,
                                  let vaccineServerId = Int(vaccine.serverId) else { return }
                            let success = await viewModel.addVaccination(
                                childUUID: childUUID,
                                vaccineId: vaccineServerId,
                                date: applicationDate,
                                facility: healthFacility.isEmpty ? nil : healthFacility,
                                notes: notes.isEmpty ? nil : notes
                            )
                            if success {
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Confirmar Registro")
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(viewModel.isLoading || selectedVaccine == nil)
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
}
