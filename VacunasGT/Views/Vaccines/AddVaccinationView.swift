import SwiftUI

struct AddVaccinationView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedVaccineId: Int = 1
    @State private var applicationDate: Date = Date()
    @State private var healthFacility: String = ""
    @State private var notes: String = ""
    
    // Lista simplificada basada en el catálogo típico
    let vaccines = [
        (id: 1, name: "BCG"),
        (id: 2, name: "Hepatitis B"),
        (id: 3, name: "Polio (IPV/OPV)"),
        (id: 4, name: "Pentavalente"),
        (id: 5, name: "Neumococo"),
        (id: 6, name: "Rotavirus"),
        (id: 7, name: "SPR (Sarampión, Paperas, Rubeola)"),
        (id: 8, name: "DPT (Refuerzo)"),
        (id: 9, name: "Influenza"),
        (id: 10, name: "Hepatitis A")
    ]
    
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
                                Picker("Vacuna", selection: $selectedVaccineId) {
                                    ForEach(vaccines, id: \.id) { vaccine in
                                        Text(vaccine.name).tag(vaccine.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.primary)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
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
                            let success = await viewModel.addVaccination(
                                childUUID: childUUID,
                                vaccineId: selectedVaccineId,
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
                    .disabled(viewModel.isLoading)
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
