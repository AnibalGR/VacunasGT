import Foundation

// MARK: - API Payloads (Requests)

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
    let device_name: String
}

struct RegisterRequest: Codable, Sendable {
    let name: String
    let email: String
    let password: String
    let password_confirmation: String
    let dpi: String
    let phone: String
    let device_name: String
}

// MARK: - API Responses

struct AuthResponse: Codable, Sendable {
    let message: String
    let parent: User
    let access_token: String
    let token_type: String
}

// Representa el modelo User / Parent que retorna Autenticación
struct User: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let email: String
    let measurement_preference: String?
    let children: [ChildDTO]?
}
// Perfil del usuario autenticado con hijos
struct UserProfileDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let email: String
    let measurement_preference: String?
    let children: [ChildDTO]?
    
    var asUser: User {
        User(id: id, name: name, email: email, measurement_preference: measurement_preference, children: children)
    }
}

