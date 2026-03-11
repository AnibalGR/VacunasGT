import SwiftUI

struct AddGrowthView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var recordedAt: Date = Date()
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var headCirc: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Nuevo Control de Crecimiento")
                                .font(.headline)
                                .foregroundColor(.brandNavy)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading) {
                                Text("Fecha del Control")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                                DatePicker("Fecha del Control", selection: $recordedAt, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.graphical)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Peso (kg)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0.0", text: $weight)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Talla (cm)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0.0", text: $height)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal)
                            
                            CustomTextField(text: $notes, placeholder: "Notas del pediatra", icon: "text.quote")
                                .padding(.horizontal)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            let success = await viewModel.addGrowthRecord(
                                childUUID: childUUID,
                                date: recordedAt,
                                weight: Double(weight),
                                height: Double(height),
                                head: Double(headCirc),
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
                            Text("Guardar Control")
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(viewModel.isLoading)
                    .padding()
                }
            }
            .navigationTitle("Crecimiento")
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

