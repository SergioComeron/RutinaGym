//
//  Untitled.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftData
import Foundation

@Model
final class Entrenamiento: Identifiable {
    var nombre: String = ""
    var fecha: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Serie.entrenamiento)
    var series: [Serie]? = []

    // Otros datos que desees agregar

    init(nombre: String, fecha: Date = Date(), series: [Serie] = []) {
        self.nombre = nombre
        self.fecha = fecha
        self.series = series
    }
}

