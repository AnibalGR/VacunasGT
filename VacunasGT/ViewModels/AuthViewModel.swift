import SwiftUI
import Combine
import SwiftData

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hasError: Bool = false

    private let authService = AuthService()
    private let childrenService = ChildrenService()

    // Contexto de SwiftData inyectado desde la vista raíz
    var modelContext: ModelContext?

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
                print("Fallo al obtener perfil en checkSession: \(error)")
            }

            if let context = modelContext {
                await VaccineManager.shared.syncFromServer(modelContext: context)
                await MilestoneManager.shared.syncFromServer(modelContext: context)
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
            do {
                let profile = try await childrenService.getUserProfile()
                self.currentUser = profile.asUser
            } catch {
                print("Fallo al obtener /user: \(error)")
            }
            self.isAuthenticated = true

            if let context = modelContext {
                await VaccineManager.shared.syncFromServer(modelContext: context)
                await MilestoneManager.shared.syncFromServer(modelContext: context)
            }
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
            do {
                let profile = try await childrenService.getUserProfile()
                self.currentUser = profile.asUser
            } catch {
                print("Fallo al obtener /user: \(error)")
            }
            self.isAuthenticated = true

            if let context = modelContext {
                await VaccineManager.shared.syncFromServer(modelContext: context)
                await MilestoneManager.shared.syncFromServer(modelContext: context)
            }
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
