//
//  Untitled.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftData
import Foundation

enum TipoSerie: String, Codable, CaseIterable {
    case normal
    case dropSet
    case alFallo
    case mediaEntera
}

@Model
final class Serie: Identifiable {
    var repeticiones: Int = 15
    var descripcion: String?
    var ejercicios: Ejercicio?
    var tipoSerie: TipoSerie = TipoSerie.normal
    var observaciones: String?

    var entrenamiento: Entrenamiento?

    init(repeticiones: Int, descripcion: String? = nil, ejercicios: Ejercicio, tipoSerie: TipoSerie, entrenamiento: Entrenamiento? = nil, observaciones: String? = nil) {
        self.repeticiones = repeticiones
        self.descripcion = descripcion
        self.ejercicios = ejercicios
        self.tipoSerie = tipoSerie
        self.entrenamiento = entrenamiento
        self.observaciones = observaciones
    }
}

