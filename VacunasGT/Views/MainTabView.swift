import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Dashboard (Inicio)
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            // Reutilizamos Dashboard para el listado de "Niños" (pueden ser filtros distintos luego)
            DashboardView()
                .tabItem {
                    Label("Niños", systemImage: "person.2.fill")
                }
            
            // Perfil Real
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(.brandNavy) // Color de acento para la pestaña activa
    }
}


