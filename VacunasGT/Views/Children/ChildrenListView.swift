import SwiftUI

struct ChildrenListView: View {
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @State private var showingAddChild = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                if childrenViewModel.isLoading && childrenViewModel.children.isEmpty {
                    ProgressView()
                } else if childrenViewModel.children.isEmpty {
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
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(childrenViewModel.children) { child in
                                NavigationLink(destination: ChildDetailView(childUUID: child.uuid, childName: child.name)) {
                                    ChildCard(child: child)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mis Niños")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddChild = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.brandNavy)
                    }
                }
            }
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
