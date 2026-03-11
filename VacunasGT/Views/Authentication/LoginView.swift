import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Curvo que ignora safe area superior
                HeaderView()
                
                VStack(spacing: 25) {
                    
                    // Campos de Texto
                    CustomTextField(text: $email, placeholder: "Correo electrónico", icon: "envelope")
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    CustomSecureField(text: $password, isVisible: $isPasswordVisible, placeholder: "Contraseña", icon: "lock")
                
                    // Manejo de Errores
                    if authViewModel.hasError, let errorMsg = authViewModel.errorMessage {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                
                    // Botón Iniciar Sesión
                    Button(action: {
                        Task {
                            let request = LoginRequest(email: email, password: password, device_name: "iPhone App")
                            await authViewModel.login(request: request)
                        }
                    }) {
                        Text("Iniciar Sesión")
                            .primaryButtonStyle(isLoading: authViewModel.isLoading)
                            .overlay {
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                }
                            }
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                    .padding(.top, 10)
                    
                    // Enlaces
                    VStack(spacing: 15) {
                        Button("¿Olvidaste tu contraseña?") { }
                            .font(.subheadline)
                            .foregroundColor(.brandNavy)
                        
                        NavigationLink(destination: RegisterView()) {
                            Text("¿No tienes cuenta? Regístrate")
                                .font(.subheadline.bold())
                                .foregroundColor(.brandNavy)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                
            }
            .background(Color.brandBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        ZStack {
            // Fondo Navy que se extiende hacia arriba
            Color.brandNavy
                .ignoresSafeArea(edges: .top)
                .frame(height: 180)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 100, bottomTrailingRadius: 100))
            
            VStack(spacing: 12) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 45))
                Text("Niño Sano GT")
                    .font(.title2.bold())
            }
            .foregroundColor(.white)
        }
    }
}



