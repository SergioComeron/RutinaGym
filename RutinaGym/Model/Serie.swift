//
//  Untitled.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftData
import Foundation

enum TipoSerie: String, Codable, CaseIterable {
    case subiendoPeso
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
    var tipoSerie: TipoSerie = TipoSerie.subiendoPeso
    var observaciones: String?
    var fechaCreacion: Date = Date()
    
    var entrenamiento: Entrenamiento?
    
    init(repeticiones: Int, descripcion: String?, ejercicios: Ejercicio?, tipoSerie: TipoSerie, observaciones: String?) {
        self.repeticiones = repeticiones
        self.descripcion = descripcion
        self.ejercicios = ejercicios
        self.tipoSerie = tipoSerie
        self.observaciones = observaciones
        self.fechaCreacion = Date() // Establecemos la fecha actual
    }
}


