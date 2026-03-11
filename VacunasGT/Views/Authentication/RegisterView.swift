import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var dpi = ""
    @State private var phone = ""
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Text("Crea tu cuenta")
                            .font(.largeTitle.bold())
                            .foregroundColor(.brandNavy)
                        
                        Text("Ingresa tus datos para comenzar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 15) {
                        CustomTextField(text: $name, placeholder: "Nombre Completo", icon: "person")
                        CustomTextField(text: $dpi, placeholder: "DPI (13 dígitos)", icon: "doc.text.viewfinder")
                            .keyboardType(.numberPad)
                        CustomTextField(text: $phone, placeholder: "Teléfono", icon: "phone")
                            .keyboardType(.phonePad)
                        CustomTextField(text: $email, placeholder: "Correo electrónico", icon: "envelope")
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        CustomSecureField(text: $password, isVisible: $isPasswordVisible, placeholder: "Contraseña", icon: "lock")
                        CustomSecureField(text: $passwordConfirmation, isVisible: $isPasswordVisible, placeholder: "Confirmar Contraseña", icon: "lock")
                    }
                    
                    if authViewModel.hasError, let errorMsg = authViewModel.errorMessage {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task {
                            let request = RegisterRequest(
                                name: name,
                                email: email,
                                password: password,
                                password_confirmation: passwordConfirmation,
                                dpi: dpi,
                                phone: phone,
                                device_name: "iPhone App"
                            )
                            await authViewModel.register(request: request)
                        }
                    }) {
                        Text("Registrarme")
                            .primaryButtonStyle(isLoading: authViewModel.isLoading)
                            .overlay {
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                }
                            }
                    }
                    .disabled(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
                    .padding(.top, 10)
                    
                    Button(action: { dismiss() }) {
                        Text("Ya tengo cuenta. Iniciar Sesión")
                            .font(.subheadline.bold())
                            .foregroundColor(.brandNavy)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.brandNavy)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}



