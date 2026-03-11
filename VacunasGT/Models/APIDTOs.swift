@preconcurrency import Foundation

// MARK: - API DTOs (Data Transfer Objects)

/// Representa a un niño en el sistema
struct ChildDTO: Codable, Identifiable, Sendable {
    let id: String
    let uuid: String
    let name: String
    let birth_date: String
    let gender: String
    let blood_type: String?
    let parent_profile_id: Int?
    let age_in_months: Int?
    let vaccines: [VaccinationRecordDTO]?
    let growth_measurements: [GrowthRecordDTO]?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, birth_date, gender, blood_type
        case parent_profile_id
        case age_in_months
        case vaccines
        case growth_measurements
    }
    
    init(
        id: String = "",
        uuid: String = "",
        name: String = "",
        birth_date: String = "",
        gender: String = "male",
        blood_type: String? = nil,
        parent_profile_id: Int? = nil,
        age_in_months: Int? = nil,
        vaccines: [VaccinationRecordDTO]? = nil,
        growth_measurements: [GrowthRecordDTO]? = nil
    ) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.birth_date = birth_date
        self.gender = gender
        self.blood_type = blood_type
        self.parent_profile_id = parent_profile_id
        self.age_in_months = age_in_months
        self.vaccines = vaccines
        self.growth_measurements = growth_measurements
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = String(idInt)
        } else if let idUUID = try? container.decode(UUID.self, forKey: .id) {
            self.id = idUUID.uuidString
        } else {
            self.id = ""
        }
        self.uuid = (try? container.decode(String.self, forKey: .uuid)) ?? self.id
        self.name = try container.decode(String.self, forKey: .name)
        self.birth_date = try container.decode(String.self, forKey: .birth_date)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.blood_type = try? container.decode(String.self, forKey: .blood_type)
        self.parent_profile_id = try? container.decode(Int.self, forKey: .parent_profile_id)
        self.age_in_months = try? container.decode(Int.self, forKey: .age_in_months)
        self.vaccines = try? container.decode([VaccinationRecordDTO].self, forKey: .vaccines)
        self.growth_measurements = try? container.decode([GrowthRecordDTO].self, forKey: .growth_measurements)
    }
}

extension ChildDTO {
    var isMale: Bool {
        let g = gender.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return g == "male" || g == "masculino" || g == "m"
    }

    var genderDisplay: String {
        isMale ? "Masculino" : "Femenino"
    }
    
    var birthDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: birth_date) ?? Date()
    }
}

/// Récord completo de un niño incluyendo historial de vacunas y crecimiento
struct ChildFullRecordDTO: Decodable, Sendable {
    let child: ChildDTO
    let vaccinations: [VaccinationRecordDTO]
    let growth_records: [GrowthRecordDTO]

    private enum CodingKeys: String, CodingKey {
        case child
        case vaccinations
        case vaccines // alternate key
        case growth_records
        case growth_measurements // alternate key
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // child can be nested or the top-level object; we'll try to decode it from `child` or synthesize from partials if needed
        if let childValue = try? container.decode(ChildDTO.self, forKey: .child) {
            self.child = childValue
        } else {
            // Fallback: decode a standalone ChildDTO from the top-level using a single-value container
            let single = try decoder.singleValueContainer()
            self.child = try single.decode(ChildDTO.self)
        }

        // vaccinations can come under `vaccinations` or `vaccines`
        if let vaccs = try? container.decode([VaccinationRecordDTO].self, forKey: .vaccinations) {
            self.vaccinations = vaccs
        } else if let vaccsAlt = try? container.decode([VaccinationRecordDTO].self, forKey: .vaccines) {
            self.vaccinations = vaccsAlt
        } else {
            self.vaccinations = []
        }

        // growth records can come under `growth_records` or `growth_measurements`
        if let growth = try? container.decode([GrowthRecordDTO].self, forKey: .growth_records) {
            self.growth_records = growth
        } else if let growthAlt = try? container.decode([GrowthRecordDTO].self, forKey: .growth_measurements) {
            self.growth_records = growthAlt
        } else {
            self.growth_records = []
        }
    }
}

/// Registro de una vacuna aplicada
struct VaccinationRecordDTO: Codable, Identifiable, Sendable {
    let id: Int
    let child_id: Int
    let vaccine_catalog_id: Int
    let application_date: String
    let lot_number: String?
    let health_facility: String?
    let notes: String?
    let vaccine: VaccineDTO?
    
    var date: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: application_date) ?? Date()
    }
}

/// Registro de crecimiento (peso, talla, etc.)
struct GrowthRecordDTO: Codable, Identifiable, Sendable {
    let id: Int
    let child_id: Int
    let recorded_at: String
    let weight_kg: Double?
    let height_cm: Double?
    let head_circumference_cm: Double?
    let notes: String?
    
    var date: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: recorded_at) ?? Date()
    }
}

/// Información del catálogo de vacunas
struct VaccineDTO: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let doses: String?
    let recommended_age_months: Int?
    let description: String?
}

// MARK: - Request Payloads

struct CreateChildRequest: Codable, Sendable {
    let name: String
    let birth_date: String
    let gender: String
    let blood_type: String?
}

struct UpdateChildRequest: Codable, Sendable {
    let name: String
    let birth_date: String
    let gender: String
    let blood_type: String?
}

struct CreateVaccinationRequest: Codable, Sendable {
    let vaccine_catalog_id: Int
    let application_date: String
    let lot_number: String?
    let health_facility: String?
    let notes: String?
}

struct CreateGrowthRecordRequest: Codable, Sendable {
    let recorded_at: String
    let weight_kg: Double?
    let height_cm: Double?
    let head_circumference_cm: Double?
    let notes: String?
}

