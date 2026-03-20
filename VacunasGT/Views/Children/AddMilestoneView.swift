import SwiftUI
import SwiftData

struct AddMilestoneView: View {
    let childUUID: String
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: ChildrenViewModel
    
    @Query(sort: \Milestone.expectedMonthMin)
    private var allMilestones: [Milestone]
    
    @State private var selectedMilestoneId: Int?
    @State private var achievedAt: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving = false
    
    // Todas las categorías
    let categories = ["Motor Grueso", "Motor Fino", "Lenguaje", "Social", "Cognitivo"]
    
    // Filtrar hitos que aún no se han registrado
    private var availableMilestones: [Milestone] {
        guard let achievedIds = viewModel.selectedChildRecord?.child.milestones?.compactMap({ $0.milestone_catalog_id }) else {
            return allMilestones
        }
        return allMilestones.filter { !achievedIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Hito Alcanzado")) {
                    if availableMilestones.isEmpty {
                        Text("¡Todos los hitos han sido registrados!")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        Picker("Selecciona el logro", selection: $selectedMilestoneId) {
                            Text("Selecciona una opción").tag(Int?.none)
                            ForEach(categories, id: \.self) { category in
                                let milestonesInCategory = availableMilestones.filter { $0.category == category }
                                if !milestonesInCategory.isEmpty {
                                    Divider()
                                    ForEach(milestonesInCategory, id: \.id) { milestone in
                                        Text("\(milestone.name) (\(milestone.expectedMonthMin)-\(milestone.expectedMonthMax) meses)")
                                            .tag(Int?(milestone.id))
                                    }
                                }
                            }
                        }
                    }
                }
                
                if let _ = selectedMilestoneId {
                    Section(header: Text("Fecha y Notas")) {
                        DatePicker(
                            "Fecha de logro",
                            selection: $achievedAt,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .tint(.brandNavy)
                        
                        TextField("Notas o detalles (opcional)", text: $notes)
                            .textInputAutocapitalization(.sentences)
                    }
                }
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
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveMilestone()
                    }
                    .bold()
                    .disabled(selectedMilestoneId == nil || isSaving)
                    .foregroundColor((selectedMilestoneId == nil || isSaving) ? .gray : .brandNavy)
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
                notes: notes
            )
            
            isSaving = false
            if success {
                dismiss()
            }
        }
    }
}
