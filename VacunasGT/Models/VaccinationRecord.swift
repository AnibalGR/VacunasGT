//
//  VaccinationRecord.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

@Model
final class VaccinationRecord {
    var fechaAplicacion: Date?
    var lugar: String?
    var isCompleted: Bool
    @Attribute(.externalStorage) var evidenceImage: Data?
    
    // Relaciones
    var child: Child?
    var vaccine: Vaccine? // Relación con la definición de la vacuna
    
    init(fechaAplicacion: Date? = nil, lugar: String? = nil, isCompleted: Bool = false, evidenceImage: Data? = nil, child: Child? = nil, vaccine: Vaccine? = nil) {
        self.fechaAplicacion = fechaAplicacion
        self.lugar = lugar
        self.isCompleted = isCompleted
        self.evidenceImage = evidenceImage
        self.child = child
        self.vaccine = vaccine
    }
}
