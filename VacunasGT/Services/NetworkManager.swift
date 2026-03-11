import Foundation

final class NetworkManager: @unchecked Sendable {
    static let shared = NetworkManager()
    
    // TODO: Mover esto a un archivo de configuración o .env en un proyecto real
    let baseURL = "https://paseosantander.com/api/v1"
    private let appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    private let platform: String = "ios"
    
    private init() {}
    
    /// Crea y configura un URLRequest con los headers por defecto
    func createRequest(endpoint: String, method: String, body: Data? = nil, requiresAuth: Bool = true) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(platform, forHTTPHeaderField: "X-App-Platform")
        request.setValue(appVersion, forHTTPHeaderField: "X-App-Version")
        
        if let body = body {
            request.httpBody = body
        }
        
        if requiresAuth, let token = KeychainStore.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// Ejecuta una petición y decodifica el resultado esperado
    func fetch<T: Decodable>(request: URLRequest, responseType: T.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            // Validar código de estado
            if !(200...299).contains(httpResponse.statusCode) {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                }
                
                let errorPayload = String(data: data, encoding: .utf8)
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, payload: errorPayload)
            }
            
            // Si los datos están vacíos para un código de éxito, intentamos devolver un objeto vacío si T lo permite o lanzamos error específico
            if data.isEmpty {
                if T.self == APIMessageResponse.self {
                    return APIMessageResponse(message: "Operación exitosa") as! T
                }
                // Si esperamos algo más pero no hay datos, lanzamos error de no datos
                throw NetworkError.noData
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                // Si la decodificación falla pero es un éxito y T es APIMessageResponse, podrìamos ser tolerantes
                if T.self == APIMessageResponse.self {
                    return APIMessageResponse(message: "Operación exitosa (sin mensaje)") as! T
                }
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

