import SwiftUI
import SwiftData
import PhotosUI

struct AddMilestoneView: View {
    let childUUID: String
    var preselectedMilestoneId: Int? = nil
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: ChildrenViewModel
    
    @Query(sort: \Milestone.expectedMonthMin)
    private var allMilestones: [Milestone]
    
    @State private var selectedMilestoneId: Int?
    @State private var achievedAt: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    
    // Fotos
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @State private var photoImage: UIImage? = nil
    
    let categories = ["Motor Grueso", "Motor Fino", "Lenguaje", "Social", "Cognitivo"]
    
    private var availableMilestones: [Milestone] {
        guard let achievedIds = viewModel.selectedChildRecord?.child.milestones?.compactMap({ $0.milestone_catalog_id }) else {
            return allMilestones
        }
        return allMilestones.filter { !achievedIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Área de foto
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 220)
                            
                            if let uiImage = photoImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.brandNavy.opacity(0.6))
                                    Text("Añadir Foto")
                                        .font(.headline)
                                        .foregroundColor(.brandNavy.opacity(0.8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: photoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                photoData = data
                                photoImage = image
                            }
                        }
                    }
                    
                    VStack(spacing: 20) {
                        // Selección de hito
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hito de Desarrollo")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if preselectedMilestoneId != nil {
                                // Vista de solo lectura (Hito preseleccionado desde una tarjeta)
                                HStack {
                                    if let id = selectedMilestoneId, let m = allMilestones.first(where: { $0.id == id }) {
                                        Text(m.name)
                                            .foregroundColor(.primary)
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            } else {
                                // Vista seleccionable interactiva
                                Menu {
                                    ForEach(categories, id: \.self) { category in
                                        let items = availableMilestones.filter { $0.category == category }
                                        if !items.isEmpty {
                                            Text(category).font(.headline)
                                            ForEach(items, id: \.id) { milestone in
                                                Button("\(milestone.name) (\(milestone.expectedMonthMin)-\(milestone.expectedMonthMax)m)") {
                                                    selectedMilestoneId = milestone.id
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if let id = selectedMilestoneId, let m = allMilestones.first(where: { $0.id == id }) {
                                            Text(m.name)
                                                .foregroundColor(.primary)
                                        } else {
                                            Text("Selecciona una opción")
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        // Fecha
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de Logro")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            DatePicker(
                                "",
                                selection: $achievedAt,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Notas
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Primeras palabras o Notas")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Ej. 'Mamá!', se veía tan sorprendido", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // Botón Guardar
                    Button(action: saveMilestone) {
                        Text("Guardar Hito")
                            .primaryButtonStyle()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }
                    .disabled(selectedMilestoneId == nil || isSaving)
                    .opacity((selectedMilestoneId == nil || isSaving) ? 0.5 : 1)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Registrar Logro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.brandNavy)
                }
            }
            .onAppear {
                if let preselected = preselectedMilestoneId {
                    selectedMilestoneId = preselected
                }
            }
            .overlay {
                if isSaving {
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Guardando...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                } else if showSuccess {
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("¡Hito guardado!")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
    
    private func saveMilestone() {
        guard let milestoneId = selectedMilestoneId else { return }
        
        Task {
            isSaving = true
            let success = await viewModel.addMilestone(
                childUUID: childUUID,
                milestoneCatalogId: milestoneId,
                achievedAt: achievedAt,
                notes: notes,
                photoData: photoData
            )
            
            isSaving = false
            if success {
                withAnimation {
                    showSuccess = true
                }
                
                // Esperar 1.5 segundos antes de cerrar el modal
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                dismiss()
            }
        }
    }
}
