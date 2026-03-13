import SwiftUI

struct ChildEditorView: View {
    let child: ChildDTO
    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var birthDate: Date
    @State private var gender: String
    @State private var bloodType: String
    
    @State private var showSuccessAlert = false

    init(child: ChildDTO) {
        self.child = child
        _name = State(initialValue: child.name)
        // Parse birth_date (YYYY-MM-DD)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        _birthDate = State(initialValue: formatter.date(from: child.birth_date) ?? Date())
        _gender = State(initialValue: child.gender.lowercased() == "female" || child.gender.lowercased() == "femenino" ? "female" : "male")
        _bloodType = State(initialValue: child.blood_type ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("Nombre")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            CustomTextField(text: $name, placeholder: "Nombre completo", icon: "person")
                        }

                        Group {
                            Text("Fecha de Nacimiento")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            DatePicker("Fecha de Nacimiento", selection: $birthDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.graphical)
                                .tint(.brandNavy)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                        }

                        Group {
                            Text("Género")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            Picker("Género", selection: $gender) {
                                Text("Masculino").tag("male")
                                Text("Femenino").tag("female")
                            }
                            .pickerStyle(.segmented)
                            .tint(.brandNavy)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                        }

                        Group {
                            Text("Tipo de Sangre")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            CustomTextField(text: $bloodType, placeholder: "Ej. O+", icon: "drop.fill")
                        }

                        Button(action: save) {
                            if viewModel.isLoading { ProgressView().tint(.white) } else { Text("Guardar Cambios") }
                        }
                        .primaryButtonStyle(isLoading: viewModel.isLoading)
                        .padding(.top, 12)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Editar Niño")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                        .foregroundColor(.brandNavy)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert("Cambios guardados", isPresented: $showSuccessAlert) {
                Button("Aceptar", role: .cancel) { dismiss() }
            } message: {
                Text("Los datos del paciente han sido actualizados exitosamente.")
            }
        }
    }

    private func save() {
        Task {
            let success = await viewModel.updateChild(uuid: child.uuid, name: name, birthDate: birthDate, gender: gender, bloodType: bloodType.isEmpty ? nil : bloodType)
            if success { 
                showSuccessAlert = true 
            }
        }
    }
}


