//
//  EntrenamientoRealizado.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//

import SwiftData
import Foundation

@Model
final class EntrenamientoRealizado: Identifiable {
    var entrenamientoPlanificado: Entrenamiento?
    var fechaInicio: Date? = Date()
    var fechaFin: Date? = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \SerieRealizada.entrenamientoRealizado)
    var seriesRealizadas: [SerieRealizada]? = []
    
    init(entrenamientoPlanificado: Entrenamiento, fechaInicio: Date? = Date(), fechaFin: Date? = nil) {
        self.entrenamientoPlanificado = entrenamientoPlanificado
        self.fechaInicio = fechaInicio
        self.fechaFin = fechaFin
        self.seriesRealizadas = []
    }
}

