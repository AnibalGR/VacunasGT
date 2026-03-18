import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var resolvedChildren: [ChildDTO] {
        return childrenViewModel.children
    }
    
    @State private var showingAddChild = false
    @State private var selectedChildUUID: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header / Bienvenida
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Hola, \(authViewModel.currentUser?.name ?? "Papá/Mamá")")
                                    .font(.title2.bold())
                                    .foregroundColor(.brandNavy)
                                Text("Aquí está el resumen de tus niños")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await authViewModel.logout()
                                }
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Listado de Niños
                        if childrenViewModel.isLoading && resolvedChildren.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if resolvedChildren.isEmpty {
                            EmptyChildrenView(showingAddChild: $showingAddChild)
                        } else {
                            // Header con botón de agregar
                            HStack {
                                Text("Mis Niños")
                                    .font(.headline)
                                    .foregroundColor(.brandNavy)
                                Spacer()
                                Button(action: { showingAddChild = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Agregar")
                                            .font(.subheadline.bold())
                                    }
                                    .foregroundColor(.brandNavy)
                                }
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 15) {
                                ForEach(resolvedChildren) { child in
                                    NavigationLink(destination: ChildDetailView(childUUID: child.uuid, childName: child.name)) {
                                        ChildCard(child: child)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Próximas Vacunas (Placeholder por ahora)
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Próximas Vacunas")
                                .font(.headline)
                                .foregroundColor(.brandNavy)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(0..<3) { _ in
                                        UpcomingVaccineCard()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Niño Sano GT")
            .navigationBarHidden(true)
            .refreshable {
                await childrenViewModel.fetchChildren()
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildView()
                    .environmentObject(childrenViewModel)
            }
            .onAppear {
                Task {
                    await childrenViewModel.fetchChildren()
                }
            }
        }
    }
}

struct ChildCard: View {
    let child: ChildDTO

    var body: some View {
        HStack(spacing: 16) {
            ChildAvatarView(
                childUUID: child.uuid,
                name: child.name,
                photoURL: child.photo_url,
                size: 56
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.headline)
                    .foregroundColor(.brandNavy)

                Text(child.genderDisplay)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.brandNavy.opacity(0.3))
        }
        .cardStyle()
    }
}

struct EmptyChildrenView: View {
    @Binding var showingAddChild: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.brandNavy.opacity(0.2))
            
            Text("Aún no tienes niños registrados")
                .font(.headline)
                .foregroundColor(.brandNavy)
            
            Text("Registra a tus hijos para llevar el control de sus vacunas y crecimiento.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddChild = true }) {
                Text("Registrar Primer Niño")
                    .primaryButtonStyle()
                    .frame(width: 250)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct UpcomingVaccineCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "syringe.fill")
                    .foregroundColor(.brandNavy)
                Text("SPR (1ra Dosis)")
                    .font(.subheadline.bold())
                    .foregroundColor(.brandNavy)
            }
            
            Text("Pendiente")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(8)
            
            Text("En 2 semanas")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}


