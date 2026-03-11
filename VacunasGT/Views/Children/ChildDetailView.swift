import SwiftUI

struct ChildDetailView: View {
    let childUUID: String
    let childName: String
    
    @EnvironmentObject var viewModel: ChildrenViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingAddVaccination = false
    @State private var showingAddGrowth = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con info del niño
            VStack(spacing: 15) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                
                Text(childName)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(Color.brandNavy)
            
            // Selector de Pestañas
            Picker("Sección", selection: $selectedTab) {
                Text("Vacunas").tag(0)
                Text("Crecimiento").tag(1)
                Text("Info").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color.brandBackground)
            
            // Contenido
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.selectedChildRecord == nil {
                    ProgressView()
                } else if let record = viewModel.selectedChildRecord {
                    if selectedTab == 0 {
                        VaccinationsList(vaccinations: record.vaccinations)
                    } else if selectedTab == 1 {
                        GrowthRecordList(records: record.growth_records)
                    } else {
                        ChildInfoView(child: record.child)
                    }
                } else {
                    Text("No se pudo cargar la información")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if selectedTab == 0 {
                        showingAddVaccination = true
                    } else if selectedTab == 1 {
                        showingAddGrowth = true
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink(destination: ChildEditorView(child: viewModel.children.first(where: { $0.uuid == childUUID }) ?? (viewModel.selectedChildRecord?.child ?? ChildDTO(id: childUUID, uuid: childUUID, name: childName)))) {
                        Label("Editar", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingAddVaccination) {
            AddVaccinationView(childUUID: childUUID)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingAddGrowth) {
            AddGrowthView(childUUID: childUUID)
                .environmentObject(viewModel)
        }
        .confirmationDialog("¿Eliminar perfil?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Eliminar a \(childName)", role: .destructive) {
                Task {
                    let success = await viewModel.deleteChild(uuid: childUUID)
                    if success {
                        dismiss()
                    }
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer y se borrarán todos los registros de vacunas y crecimiento.")
        }
        .onAppear {
            Task {
                await viewModel.fetchChildRecord(uuid: childUUID)
            }
        }
        .alert("Error", isPresented: $viewModel.hasError) {
            Button("Cerrar", role: .cancel) {
                viewModel.hasError = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "Ocurrió un error inesperado")
        }
    }
}

struct VaccinationsList: View {
    let vaccinations: [VaccinationRecordDTO]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if vaccinations.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "syringe.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary.opacity(0.3))
                        Text("No hay vacunas registradas")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    ForEach(vaccinations) { record in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(record.vaccine?.name ?? "Vacuna")
                                    .font(.headline)
                                    .foregroundColor(.brandNavy)
                                Spacer()
                                Text(record.application_date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let facility = record.health_facility {
                                Label(facility, systemImage: "hospital.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                }
            }
            .padding()
        }
    }
}

struct GrowthRecordList: View {
    let records: [GrowthRecordDTO]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if records.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.secondary.opacity(0.3))
                        Text("No hay registros de crecimiento")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    ForEach(records) { record in
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text(record.recorded_at)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.brandNavy)
                            }
                            
                            Spacer()
                            
                            if let weight = record.weight_kg {
                                GrowthItem(label: "Peso", value: "\(weight) kg", icon: "scalemass.fill")
                            }
                            
                            if let height = record.height_cm {
                                GrowthItem(label: "Talla", value: "\(height) cm", icon: "ruler.fill")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                }
            }
            .padding()
        }
    }
}

struct GrowthItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.brandNavy)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.brandNavy)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
}

struct ChildInfoView: View {
    let child: ChildDTO
    
    var body: some View {
        List {
            Section(header: Text("Datos Generales")) {
                InfoRow(label: "Nombre", value: child.name)
                InfoRow(label: "Fecha de Nacimiento", value: child.birth_date)
                InfoRow(label: "Género", value: child.genderDisplay)
                InfoRow(label: "Tipo de Sangre", value: child.blood_type ?? "No especificado")
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(.brandNavy)
        }
    }
}
