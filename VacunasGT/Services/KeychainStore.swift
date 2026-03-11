import Foundation
import Security

/// Un wrapper simple nativo sobre Keychain Services para almacenar el Token de sesión
final class KeychainStore {
    static let shared = KeychainStore()
    private let tokenKey = "com.ninoshano.accesstoken"
    
    private init() {}
    
    /// Guarda el token en Keychain de forma segura
    @discardableResult
    func saveToken(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        // Primero eliminamos cualquier token previo para evitar duplicados
        SecItemDelete(query as CFDictionary)
        
        // Añadimos el nuevo token
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Lee el token desde Keychain
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    /// Elimina el token (Logout)
    @discardableResult
    func deleteToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// Verifica si hay sesión activa basándose en la existencia del token
    var hasToken: Bool {
        return getToken() != nil
    }
}
