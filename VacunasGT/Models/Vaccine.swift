//
//  Vaccine.swift
//  VacunasGT
//

import Foundation
import SwiftData

@Model
final class Vaccine {
    @Attribute(.unique) var serverId: String
    var nombre: String
    var dosis: String
    var edadRecomendadaMeses: Int
    var descripcion: String
    var isPrivate: Bool
    var isMandatory: Bool

    init(
        serverId: String,
        nombre: String,
        dosis: String,
        edadRecomendadaMeses: Int,
        descripcion: String,
        isPrivate: Bool = false,
        isMandatory: Bool = true
    ) {
        self.serverId = serverId
        self.nombre = nombre
        self.dosis = dosis
        self.edadRecomendadaMeses = edadRecomendadaMeses
        self.descripcion = descripcion
        self.isPrivate = isPrivate
        self.isMandatory = isMandatory
    }
}
