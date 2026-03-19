import SwiftUI
import Combine

@MainActor
class ChildrenViewModel: ObservableObject {
    @Published var children: [ChildDTO] = []
    @Published var selectedChildRecord: ChildFullRecordDTO? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hasError: Bool = false
    
    private let childrenService = ChildrenService()
    private let vaccinationService = VaccinationService()
    private let growthService = GrowthService()
    private let milestoneService = MilestoneService()
    
    /// Carga la lista de niños del padre
    func fetchChildren() async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            self.children = try await childrenService.getChildren()
        } catch {
            self.handleError(error)
        }
        
        isLoading = false
    }
    
    /// Carga el récord completo de un niño específico
    func fetchChildRecord(uuid: String) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            self.selectedChildRecord = try await childrenService.getChildRecord(uuid: uuid)
        } catch {
            self.handleError(error)
        }
        
        isLoading = false
    }
    
    /// Agrega un nuevo niño
    func addChild(name: String, birthDate: Date, gender: String, bloodType: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: birthDate)
        
        let payload = CreateChildRequest(
            name: name,
            birth_date: dateString,
            gender: gender,
            blood_type: bloodType
        )
        
        do {
            let newChild = try await childrenService.createChild(payload: payload)
            self.children.append(newChild)
            isLoading = false
            return true
        } catch {
            self.handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Registra una vacuna aplicada
    func addVaccination(childUUID: String, vaccineId: Int, date: Date, facility: String?, notes: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        let payload = CreateVaccinationRequest(
            vaccine_catalog_id: vaccineId,
            application_date: formatter.string(from: date),
            lot_number: nil,
            health_facility: facility,
            notes: notes
        )
        
        do {
            _ = try await vaccinationService.recordVaccination(childUUID: childUUID, payload: payload)
            await fetchChildRecord(uuid: childUUID)
            return true
        } catch {
            self.handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Registra un control de crecimiento
    func addGrowthRecord(childUUID: String, date: Date, weight: Double?, height: Double?, head: Double?, notes: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        let payload = CreateGrowthRecordRequest(
            recorded_at: formatter.string(from: date),
            weight_kg: weight,
            height_cm: height,
            head_circumference_cm: head,
            notes: notes
        )
        
        do {
            _ = try await growthService.recordGrowth(childUUID: childUUID, payload: payload)
            await fetchChildRecord(uuid: childUUID)
            return true
        } catch {
            self.handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Actualiza un niño existente
    func updateChild(uuid: String, name: String, birthDate: Date, gender: String, bloodType: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: birthDate)
        let payload = UpdateChildRequest(name: name, birth_date: dateString, gender: gender, blood_type: bloodType)
        do {
            let updated = try await ChildrenService().updateChild(uuid: uuid, payload: payload)
            if let index = children.firstIndex(where: { $0.uuid == uuid }) {
                children[index] = updated
            }
            // Refetch in order to immediately reflect changes on DetailView Header
            await fetchChildRecord(uuid: uuid)
            
            isLoading = false
            return true
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }

    /// Elimina un niño existente
    func deleteChild(uuid: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        do {
            _ = try await ChildrenService().deleteChild(uuid: uuid)
            
            // Diferir la mutación para el siguiente ciclo del runloop
            // y evitar el "Publishing changes from within view updates"
            Task { @MainActor in
                self.children.removeAll { $0.uuid == uuid }
                self.isLoading = false
            }
            return true
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }

    /// Sube una foto de perfil al servidor y actualiza localmente
    func uploadChildPhoto(uuid: String, imageData: Data) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            let updatedChild = try await childrenService.uploadPhoto(uuid: uuid, imageData: imageData)
            
            // Actualizar en la lista local
            if let index = children.firstIndex(where: { $0.uuid == uuid }) {
                children[index] = updatedChild
            }
            
            // Refrescar el récord detallado si es el niño seleccionado
            if selectedChildRecord?.child.uuid == uuid {
                await fetchChildRecord(uuid: uuid)
            }
            
            isLoading = false
            return true
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }

    /// Elimina la foto de perfil en el servidor y actualiza localmente
    func deleteChildPhoto(uuid: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            let updatedChild = try await childrenService.deletePhoto(uuid: uuid)
            
            // Actualizar en la lista local
            if let index = children.firstIndex(where: { $0.uuid == uuid }) {
                children[index] = updatedChild
            }
            
            // Refrescar el récord detallado si es el niño seleccionado
            if selectedChildRecord?.child.uuid == uuid {
                await fetchChildRecord(uuid: uuid)
            }
            
            isLoading = false
            return true
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Agrega un nuevo hito al niño actual
    func addMilestone(childUUID: String, milestoneCatalogId: Int, achievedAt: Date, notes: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: achievedAt)
        
        let payload = CreateMilestoneRequest(
            milestone_catalog_id: milestoneCatalogId,
            achieved_at: dateString,
            notes: (notes?.isEmpty ?? true) ? nil : notes
        )
        
        do {
            _ = try await milestoneService.recordMilestone(childUUID: childUUID, payload: payload)
            // Refrescar récord
            await fetchChildRecord(uuid: childUUID)
            return true
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }
    
    /// Elimina un hito registrado
    func deleteMilestone(childUUID: String, milestoneId: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            try await milestoneService.deleteMilestone(childUUID: childUUID, milestoneId: milestoneId)
            // Refrescar récord
            await fetchChildRecord(uuid: childUUID)
            return true
        } catch {
            handleError(error)
            isLoading = false
            return false
        }
    }
    
    private func handleError(_ error: Error) {
        hasError = true
        if let networkError = error as? NetworkError {
            self.errorMessage = networkError.localizedDescription
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}
