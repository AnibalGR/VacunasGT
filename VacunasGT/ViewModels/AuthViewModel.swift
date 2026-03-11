import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hasError: Bool = false
    
    private let authService = AuthService()
    private let childrenService = ChildrenService()
    
    init() {
        checkSession()
    }
    
    /// Verifica si ya existe un token guardado al iniciar la app
    func checkSession() {
        let hasToken = KeychainStore.shared.hasToken
        self.isAuthenticated = hasToken
        guard hasToken else { return }
        
        Task {
            do {
                let profile = try await childrenService.getUserProfile()
                self.currentUser = profile.asUser
            } catch {
                // En checkSession, no cerramos sesión aunque falle /user
                // El usuario ya está autenticado con un token válido guardado
                print("Fallo al obtener perfil en checkSession: \(error)")
            }
        }
    }
    
    /// Realiza el login usando las credenciales
    func login(request: LoginRequest) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            let response = try await authService.login(requestPayload: request)
            self.currentUser = response.parent
            // Cargar perfil y niños del usuario para asegurar sincronización
            do {
                let profile = try await childrenService.getUserProfile()
                self.currentUser = profile.asUser
                // Dejamos que DashboardView dispare fetchChildren() al aparecer
            } catch {
                // Si /user falla, continuamos con los datos del login
                print("Fallo al obtener /user: \(error)")
            }
            self.isAuthenticated = true
        } catch {
            self.handleError(error)
        }
        
        isLoading = false
    }
    
    /// Registra un nuevo usuario
    func register(request: RegisterRequest) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            let response = try await authService.register(requestPayload: request)
            self.currentUser = response.parent
            // Cargar perfil y niños del usuario para asegurar sincronización
            do {
                let profile = try await childrenService.getUserProfile()
                self.currentUser = profile.asUser
                // Actualizar ChildrenViewModel si es necesario se hará por EnvironmentObject externo
            } catch {
                // Si /user falla, continuamos con los datos del login
                print("Fallo al obtener /user: \(error)")
            }
            self.isAuthenticated = true
        } catch {
            self.handleError(error)
        }
        
        isLoading = false
    }
    
    /// Cierra sesión
    func logout() async {
        isLoading = true
        do {
            _ = try await authService.logout()
        } catch {
            print("Error logout backend: \(error.localizedDescription) pero sesión limpia en local.")
        }
        
        // Siempre limpiar sesión local, independientemente del resultado del servidor
        KeychainStore.shared.deleteToken()
        self.currentUser = nil
        self.isAuthenticated = false
        self.isLoading = false
    }
    
    private func handleError(_ error: Error) {
        hasError = true
        if let networkError = error as? NetworkError {
            self.errorMessage = networkError.localizedDescription
        } else {
            self.errorMessage = "Ocurrió un error inesperado al intentar autenticarse."
        }
    }
}

