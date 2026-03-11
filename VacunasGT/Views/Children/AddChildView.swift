//
//  AddChildView.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import SwiftUI
import SwiftData

struct AddChildView: View {
    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var gender: String = "male"
    @State private var bloodType: String = ""
    
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
                ScrollView {
                    VStack(spacing: 25) {
                        // Header personalizado para mayor contraste en el modal
                        VStack(spacing: 5) {
                            Text("Nuevo Registro")
                                .font(.title3.bold())
                                .foregroundColor(.brandNavy)
                            Text("Ingresa los datos del niño(a)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Información de tu Niño(a)")
                                .font(.headline)
                                .foregroundColor(.brandNavy)
                            
                            CustomTextField(text: $name, placeholder: "Nombre completo", icon: "person")
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Fecha de Nacimiento")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            DatePicker("Fecha de Nacimiento", selection: $birthDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.graphical)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Género")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            Picker("Género", selection: $gender) {
                                Text("Masculino").tag("male")
                                Text("Femenino").tag("female")
                            }
                            .pickerStyle(.segmented)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.12), lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Datos médicos opcionales")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            CustomTextField(text: $bloodType, placeholder: "Tipo de Sangre (ej. O+)", icon: "drop.fill")
                        }
                        
                        Spacer(minLength: 30)
                        
                        Button(action: {
                            guard !isSaving else { return }
                            isSaving = true
                            Task {
                                let success = await viewModel.addChild(
                                    name: name,
                                    birthDate: birthDate,
                                    gender: gender,
                                    bloodType: bloodType.isEmpty ? nil : bloodType
                                )
                                if success {
                                    dismiss()
                                }
                                isSaving = false
                            }
                        }) {
                            Text("Guardar Registro")
                                .primaryButtonStyle(isLoading: viewModel.isLoading || isSaving)
                                .overlay {
                                    if viewModel.isLoading || isSaving {
                                        ProgressView().tint(.white)
                                    }
                                }
                        }
                        .disabled(name.isEmpty || viewModel.isLoading || isSaving)
                    }
                    .padding(30)
                }
            }
            .background(Color.brandBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.brandNavy)
                    .font(.subheadline.bold())
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}


