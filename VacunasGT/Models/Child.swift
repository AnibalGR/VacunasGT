//
//  Child.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

@Model
final class Child {
    var nombre: String
    var fechaNacimiento: Date
    var sexo: String // "M" o "F"
    @Attribute(.externalStorage) var fotoPerfil: Data?
    
    // Relaciones
    @Relationship(deleteRule: .cascade) var registrosVacunacion: [VaccinationRecord] = []
    @Relationship(deleteRule: .cascade) var registrosCrecimiento: [GrowthRecord] = []
    
    init(nombre: String, fechaNacimiento: Date, sexo: String, fotoPerfil: Data? = nil) {
        self.nombre = nombre
        self.fechaNacimiento = fechaNacimiento
        self.sexo = sexo
        self.fotoPerfil = fotoPerfil
    }
}
