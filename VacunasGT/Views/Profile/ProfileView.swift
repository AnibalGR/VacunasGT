import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Avatar Header
                    VStack(spacing: 15) {
                        Circle()
                            .fill(Color.brandNavy.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.brandNavy)
                            )
                        
                        Text(authViewModel.currentUser?.name ?? "Papá / Mamá")
                            .font(.title2.bold())
                            .foregroundColor(.brandNavy)
                        
                        Text(authViewModel.currentUser?.email ?? "email@ejemplo.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Opciones de Menú
                    VStack(spacing: 1) {
                        ProfileMenuRow(icon: "doc.text", title: "Términos y Condiciones")
                        ProfileMenuRow(icon: "shield.lefthalf.filled", title: "Privacidad")
                        ProfileMenuRow(icon: "bell", title: "Notificaciones")
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Botón Logout
                    Button(action: {
                        Task {
                            await authViewModel.logout()
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView().tint(.red)
                            } else {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                            }
                        }
                        .foregroundColor(.red)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.red, lineWidth: 1.5))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Mi Perfil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brandNavy)
                .frame(width: 25)
            Text(title)
                .foregroundColor(.brandNavy)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
    }
}


