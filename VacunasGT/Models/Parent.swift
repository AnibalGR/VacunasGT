//
//  Parent.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

@Model
final class Parent {
    var nombre: String
    var fechaRegistro: Date
    
    // Podríamos agregar más campos en el futuro (email, preferencias)
    
    init(nombre: String, fechaRegistro: Date = Date()) {
        self.nombre = nombre
        self.fechaRegistro = fechaRegistro
    }
}
