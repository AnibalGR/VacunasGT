import SwiftUI
import SwiftData

struct MilestonesListView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    @State private var viewMode: Int = 0 // 0 = Explorar, 1 = Álbum
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Modo de Vista", selection: $viewMode) {
                Text("Explorar").tag(0)
                Text("Álbum").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(.systemGray6))
            
            if viewMode == 0 {
                MilestoneDeckView(childUUID: childUUID)
            } else {
                MilestoneAlbumView(childUUID: childUUID)
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

// MARK: - Deck of Cards (Hitos Pendientes)
struct MilestoneDeckView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    
    @Query(sort: \Milestone.expectedMonthMin)
    private var allMilestones: [Milestone]
    
    @State private var selectedMilestoneForRecord: Milestone?
    
    private var pendingMilestones: [Milestone] {
        let achievedIds = viewModel.selectedChildRecord?.child.milestones?.compactMap({ $0.milestone_catalog_id }) ?? []
        return allMilestones.filter { !achievedIds.contains($0.id) }
    }
    
    var body: some View {
        VStack {
            if pendingMilestones.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                    Text("¡Increíble!")
                        .font(.title2.bold())
                    Text("Has registrado todos los hitos disponibles.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 30) {
                        ForEach(pendingMilestones, id: \.id) { milestone in
                            DeckCardView(
                                milestone: milestone,
                                onComplete: {
                                    selectedMilestoneForRecord = milestone
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .sheet(item: $selectedMilestoneForRecord) { milestone in
            AddMilestoneView(childUUID: childUUID)
                .environmentObject(viewModel)
        }
    }
}

struct DeckCardView: View {
    let milestone: Milestone
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header curvo o de color (simulado)
            ZStack(alignment: .bottom) {
                Color.blue.opacity(0.1)
                
                // placeholder illustration
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "face.smiling")
                            .font(.system(size: 60))
                            .foregroundColor(.brandNavy.opacity(0.6))
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .offset(y: 60)
            }
            .frame(height: 140)
            
            Spacer().frame(height: 60)
            
            Text(milestone.name)
                .font(.title2.bold())
                .foregroundColor(.brandNavy)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(milestone.category)
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            Text("Meses: \(milestone.expectedMonthMin) - \(milestone.expectedMonthMax)")
                .font(.headline)
                .foregroundColor(.gray)
            
            // TODO: Replace `milestone.category` with the appropriate descriptive field if available (e.g., details/summary)
            if !milestone.category.isEmpty {
                Text(milestone.category)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            Button(action: onComplete) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("¡Logrado!")
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        .padding(.vertical, 10)
    }
}

// MARK: - Milestone Memory Album (Hitos Logrados)
struct MilestoneAlbumView: View {
    let childUUID: String
    @EnvironmentObject var viewModel: ChildrenViewModel
    
    @State private var selectedCategory = "Todos"
    @State private var showingDeleteConfirmation = false
    @State private var milestoneToDelete: MilestoneRecordDTO?
    
    let categories = ["Todos", "Motor Grueso", "Motor Fino", "Lenguaje", "Social", "Cognitivo"]
    
    private var achievedMilestones: [MilestoneRecordDTO] {
        let all = viewModel.selectedChildRecord?.child.milestones ?? []
        let sorted = all.sorted {
            guard let d1 = DateFormatter.yyyyMMdd.date(from: $0.achieved_at),
                  let d2 = DateFormatter.yyyyMMdd.date(from: $1.achieved_at) else { return false }
            return d1 > d2 // Más recientes primero
        }
        
        if selectedCategory == "Todos" {
            return sorted
        } else {
            return sorted.filter { $0.milestone?.category == selectedCategory }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Pills de Categorías
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation {
                                selectedCategory = category
                            }
                        } label: {
                            Text(category)
                                .font(.subheadline.bold())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.brandNavy : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .brandNavy)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding()
            }
            
            if achievedMilestones.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("Tu álbum está vacío")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("¡Completa hitos para verlos aquí!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(achievedMilestones, id: \.id) { record in
                            AlbumEntryView(record: record, onDelete: {
                                milestoneToDelete = record
                                showingDeleteConfirmation = true
                            })
                        }
                    }
                    .padding()
                    .padding(.bottom, 50)
                }
            }
        }
        .confirmationDialog(
            "¿Eliminar este recuerdo?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Eliminar hito completo", role: .destructive) {
                if let record = milestoneToDelete {
                    Task {
                        await viewModel.deleteMilestone(childUUID: childUUID, milestoneId: record.id)
                    }
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Se borrará la foto y los detalles asociados. Esta acción no se puede deshacer.")
        }
    }
}

struct AlbumEntryView: View {
    let record: MilestoneRecordDTO
    let onDelete: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: record.achieved_at) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return record.achieved_at
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Imagen miniatura
            VStack {
                if let urlString = record.photo_url, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            fallbackImage
                        case .empty:
                            ProgressView()
                        @unknown default:
                            fallbackImage
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    fallbackImage
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text(record.milestone?.name ?? "Hito")
                    .font(.caption.bold())
                    .foregroundColor(.brandNavy)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
            
            // Texto y Detalles
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.yellow)
                    Text("¡Felicidades!")
                        .font(.subheadline.bold())
                        .foregroundColor(.brandNavy)
                    Spacer()
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let notes = record.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.brandNavy.opacity(0.8))
                        .padding(.top, 4)
                } else {
                    Text("Un momento mágico guardado en la memoria.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                        .italic()
                }
            }
            
            // Botón opciones
            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Eliminar recuerdo", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var fallbackImage: some View {
        ZStack {
            Color.blue.opacity(0.1)
            Image(systemName: "photo.artframe")
                .foregroundColor(.blue.opacity(0.4))
                .font(.title)
        }
    }
}

// Extensión para formato de fecha simple
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

