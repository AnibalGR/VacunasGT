//
//  Item.swift
//  VacunasGT
//
//  Created by Anibal Gramajo on 30/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
