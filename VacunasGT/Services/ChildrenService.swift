@preconcurrency import Foundation

/// Servicio para gestionar los expedientes de los niños
final class ChildrenService: Sendable {
    
    /// Obtiene la lista de todos los niños del padre autenticado
    func getChildren() async throws -> [ChildDTO] {
        let request = try NetworkManager.shared.createRequest(endpoint: "/children", method: "GET", requiresAuth: true)
        let response: APIResponse<[ChildDTO]> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<[ChildDTO]>.self)
        return response.data
    }
    
    /// Obtiene el perfil del usuario autenticado con sus hijos
    func getUserProfile() async throws -> UserProfileDTO {
        let request = try NetworkManager.shared.createRequest(endpoint: "/user", method: "GET", requiresAuth: true)
        let profile: UserProfileDTO = try await NetworkManager.shared.fetch(request: request, responseType: UserProfileDTO.self)
        return profile
    }
    
    /// Registra un nuevo niño
    func createChild(payload: CreateChildRequest) async throws -> ChildDTO {
        let body = try JSONEncoder().encode(payload)
        let request = try NetworkManager.shared.createRequest(endpoint: "/children", method: "POST", body: body, requiresAuth: true)
        let response: APIResponse<ChildDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<ChildDTO>.self)
        return response.data
    }
    
    /// Actualiza un niño existente
    func updateChild(uuid: String, payload: UpdateChildRequest) async throws -> ChildDTO {
        var dict: [String: Any] = [
            "name": payload.name,
            "birth_date": payload.birth_date,
            "gender": payload.gender,
            "_method": "PUT"
        ]
        if let bloodType = payload.blood_type {
            dict["blood_type"] = bloodType
        }
        
        let body = try JSONSerialization.data(withJSONObject: dict)
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(uuid)", method: "POST", body: body, requiresAuth: true)
        let response: APIResponse<ChildDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<ChildDTO>.self)
        return response.data
    }

    /// Elimina un niño existente
    @discardableResult
    func deleteChild(uuid: String) async throws -> APIMessageResponse {
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(uuid)", method: "DELETE", requiresAuth: true)
        let response: APIMessageResponse = try await NetworkManager.shared.fetch(request: request, responseType: APIMessageResponse.self)
        return response
    }
    
    /// Obtiene el récord médico completo de un niño (incluye vacunas y crecimiento)
    func getChildRecord(uuid: String) async throws -> ChildFullRecordDTO {
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(uuid)", method: "GET", requiresAuth: true)
        let response: APIResponse<ChildFullRecordDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<ChildFullRecordDTO>.self)
        return response.data
    }

    /// Sube la foto de perfil al servidor
    func uploadPhoto(uuid: String, imageData: Data) async throws -> ChildDTO {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = try NetworkManager.shared.createRequest(endpoint: "/children/\(uuid)", method: "POST", requiresAuth: true)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Simular PUT para Laravel (campo _method)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"_method\"\r\n\r\n".data(using: .utf8)!)
        body.append("PUT\r\n".data(using: .utf8)!)
        
        // Campo 'photo'
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let response: APIResponse<ChildDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<ChildDTO>.self)
        return response.data
    }

    /// Elimina la foto de perfil en el servidor
    func deletePhoto(uuid: String) async throws -> ChildDTO {
        let dict: [String: Any] = [
            "_method": "PUT",
            "delete_photo": true
        ]
        let body = try JSONSerialization.data(withJSONObject: dict)
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(uuid)", method: "POST", body: body, requiresAuth: true)
        let response: APIResponse<ChildDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<ChildDTO>.self)
        return response.data
    }
}

/// Servicio para gestionar registros de vacunación
final class VaccinationService {
    
    /// Registra la aplicación de una vacuna para un niño específico
    func recordVaccination(childUUID: String, payload: CreateVaccinationRequest) async throws -> VaccinationRecordDTO {
        let body = try JSONEncoder().encode(payload)
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(childUUID)/vaccinations", method: "POST", body: body, requiresAuth: true)
        let response: APIResponse<VaccinationRecordDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<VaccinationRecordDTO>.self)
        return response.data
    }
}

/// Servicio para gestionar registros de crecimiento
final class GrowthService {
    
    /// Registra un nuevo control de peso/talla
    func recordGrowth(childUUID: String, payload: CreateGrowthRecordRequest) async throws -> GrowthRecordDTO {
        let body = try JSONEncoder().encode(payload)
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(childUUID)/growth_records", method: "POST", body: body, requiresAuth: true)
        let response: APIResponse<GrowthRecordDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<GrowthRecordDTO>.self)
        return response.data
    }
}

/// Servicio para gestionar registros de hitos
final class MilestoneService {
    
    /// Registra un nuevo hito alcanzado
    func recordMilestone(childUUID: String, payload: CreateMilestoneRequest) async throws -> MilestoneRecordDTO {
        let body = try JSONEncoder().encode(payload)
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(childUUID)/milestones", method: "POST", body: body, requiresAuth: true)
        let response: APIResponse<MilestoneRecordDTO> = try await NetworkManager.shared.fetch(request: request, responseType: APIResponse<MilestoneRecordDTO>.self)
        return response.data
    }
    
    /// Elimina un hito registrado
    @discardableResult
    func deleteMilestone(childUUID: String, milestoneId: Int) async throws -> APIMessageResponse {
        let request = try NetworkManager.shared.createRequest(endpoint: "/children/\(childUUID)/milestones/\(milestoneId)", method: "DELETE", requiresAuth: true)
        let response: APIMessageResponse = try await NetworkManager.shared.fetch(request: request, responseType: APIMessageResponse.self)
        return response
    }
}

