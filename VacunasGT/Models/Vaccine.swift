//
//  Vaccine.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

@Model
final class Vaccine {
    var nombre: String
    var dosis: String // Ej: "1ra Dosis", "Refuerzo"
    var edadRecomendadaMeses: Int
    var descripcion: String
    var isPrivate: Bool
    
    init(nombre: String, dosis: String, edadRecomendadaMeses: Int, descripcion: String, isPrivate: Bool = false) {
        self.nombre = nombre
        self.dosis = dosis
        self.edadRecomendadaMeses = edadRecomendadaMeses
        self.descripcion = descripcion
        self.isPrivate = isPrivate
    }
}
