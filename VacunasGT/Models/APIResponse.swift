@preconcurrency import Foundation

/// Estructura genérica para decodificar respuestas de la API que vienen envueltas en "data": { ... }
struct APIResponse<T: Decodable>: Decodable {
    let data: T
}

/// Respuesta genérica para endpoints que solo devuelven un mensaje
struct APIMessageResponse: Decodable {
    let message: String
}

struct LaravelErrorResponse: Decodable {
    let message: String?
    let errors: [String: [String]]?
}

/// Enumeración para manejar los posibles errores de red de forma unificada
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, payload: String?)
    case unauthorized // 401
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL proporcionada no es válida."
        case .noData:
            return "No se recibió respuesta del servidor."
        case .decodingError(let error):
            return "Error al decodificar la información: \(error.localizedDescription)"
        case .serverError(let statusCode, let payload):
            if let payloadString = payload,
               let payloadData = payloadString.data(using: .utf8),
               let parsedResponse = try? JSONDecoder().decode(LaravelErrorResponse.self, from: payloadData) {
                
                var errorMessage = parsedResponse.message ?? "Error en el servidor (\(statusCode))"
                
                if let fieldErrors = parsedResponse.errors, !fieldErrors.isEmpty {
                    let allErrors = fieldErrors.values.flatMap { $0 }
                    errorMessage += "\n" + allErrors.joined(separator: "\n")
                }
                return errorMessage
            }
            return "Error en el servidor con código: \(statusCode)."
        case .unauthorized:
            return "Sesión expirada o credenciales incorrectas."
        case .unknown(let error):
            return "Error desconocido: \(error.localizedDescription)"
        }
    }
}

