@preconcurrency import Foundation

final class AuthService {
    
    /// Iniciar sesión
    func login(requestPayload: LoginRequest) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(requestPayload)
        let request = try NetworkManager.shared.createRequest(endpoint: "/auth/login", method: "POST", body: body, requiresAuth: false)
        let response: AuthResponse = try await NetworkManager.shared.fetch(request: request, responseType: AuthResponse.self)
        
        // Guardar el token de forma segura tras el éxito
        KeychainStore.shared.saveToken(response.access_token)
        return response
    }
    
    /// Registrar nuevo usuario (padre)
    func register(requestPayload: RegisterRequest) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(requestPayload)
        let request = try NetworkManager.shared.createRequest(endpoint: "/auth/register", method: "POST", body: body, requiresAuth: false)
        let response: AuthResponse = try await NetworkManager.shared.fetch(request: request, responseType: AuthResponse.self)
        
        // Guardar el token de forma segura tras el éxito
        KeychainStore.shared.saveToken(response.access_token)
        return response
    }
    
    /// Cerrar sesión
    func logout() async throws -> APIMessageResponse {
        do {
            let request = try NetworkManager.shared.createRequest(endpoint: "/auth/logout", method: "POST", requiresAuth: true)
            let response: APIMessageResponse = try await NetworkManager.shared.fetch(request: request, responseType: APIMessageResponse.self)
            
            // Limpiar sesión local independientemente de la respuesta
            KeychainStore.shared.deleteToken()
            return response
        } catch {
            // Si el token estaba vencido o falló por red, limpiamos de todos modos localmente para no quedar atrapados
            KeychainStore.shared.deleteToken()
            throw error
        }
    }
}
