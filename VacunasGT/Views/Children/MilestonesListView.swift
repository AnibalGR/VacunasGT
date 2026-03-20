import SwiftUI
import SwiftData

struct MilestonesListView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    @State private var showingAddMilestone = false
    
    // Todas las categorías posibles de hitos
    let categories = ["Motor Grueso", "Motor Fino", "Lenguaje", "Social", "Cognitivo"]
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Título y Botón de Agregar
                HStack {
                    Text("Hitos del Desarrollo")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.brandNavy)
                    
                    Spacer()
                    
                    Button {
                        showingAddMilestone = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Registrar Hito")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.accentColor)
                }
                .padding()
                
                if let milestones = viewModel.selectedChildRecord?.child.milestones, !milestones.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(categories, id: \.self) { category in
                                let categoryMilestones = milestones.filter { $0.milestone?.category == category }
                                if !categoryMilestones.isEmpty {
                                    MilestoneCategorySection(category: category, milestones: categoryMilestones, childUUID: childUUID)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                } else {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No hay hitos registrados")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Registra el primer logro de tu hijo")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMilestone) {
            AddMilestoneView(childUUID: childUUID)
                .environmentObject(viewModel)
        }
    }
}

struct MilestoneCategorySection: View {
    let category: String
    let milestones: [MilestoneRecordDTO]
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    @State private var milestoneToDelete: MilestoneRecordDTO?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header de Categoría
            HStack {
                Text(category)
                    .font(.headline)
                    .foregroundColor(.brandNavy)
                Spacer()
                Text("\(milestones.count) hitos")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 4)
            
            // Lista de hitos
            ForEach(milestones, id: \.id) { record in
                if let milestone = record.milestone {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                            
                        VStack(alignment: .leading, spacing: 4) {
                            Text(milestone.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.brandNavy)
                                
                            Text("Logrado el \(formatDate(record.achieved_at))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                
                            if let notes = record.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.brandNavy.opacity(0.7))
                                    .italic()
                                    .padding(.top, 2)
                            }
                        }
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive) {
                                milestoneToDelete = record
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                                .padding(8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding(.vertical, 8)
        .confirmationDialog(
            "¿Eliminar este hito?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Eliminar hito", role: .destructive) {
                if let record = milestoneToDelete {
                    Task {
                        await viewModel.deleteMilestone(childUUID: childUUID, milestoneId: record.id)
                    }
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return dateString
    }
}

