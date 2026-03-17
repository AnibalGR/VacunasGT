//
//  ChildPhoto.swift
//  VacunasGT
//

import Foundation
import SwiftData

/// Almacena la foto de perfil de un niño localmente en el dispositivo.
/// Se vincula por `childUUID` para no requerir cambios en el servidor.
@Model
final class ChildPhoto {
    @Attribute(.unique) var childUUID: String
    var imageData: Data

    init(childUUID: String, imageData: Data) {
        self.childUUID = childUUID
        self.imageData = imageData
    }
}
