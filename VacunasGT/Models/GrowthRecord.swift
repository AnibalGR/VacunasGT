//
//  GrowthRecord.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

@Model
final class GrowthRecord {
    var fecha: Date
    var pesoKg: Double
    var tallaCm: Double
    
    // Relación inversa (opcional explícitamente, pero implícita por Child)
    var child: Child?
    
    init(fecha: Date, pesoKg: Double, tallaCm: Double, child: Child? = nil) {
        self.fecha = fecha
        self.pesoKg = pesoKg
        self.tallaCm = tallaCm
        self.child = child
    }
}
