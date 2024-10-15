//
//  SerieRealizada.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//

import SwiftData
import Foundation

@Model
final class SerieRealizada: Identifiable {
   
    var seriePlanificada: Serie?
    var pesoUtilizado: Double?
    var repeticionesRealizadas: Int?
    var observaciones: String = ""
    var fecha: Date = Date()
    
    var entrenamientoRealizado: EntrenamientoRealizado?
    
    init(seriePlanificada: Serie?, pesoUtilizado: Double?, repeticionesRealizadas: Int?, observaciones: String = "", entrenamientoRealizado: EntrenamientoRealizado?) {
        self.seriePlanificada = seriePlanificada
        self.pesoUtilizado = pesoUtilizado
        self.repeticionesRealizadas = repeticionesRealizadas
        self.observaciones = observaciones
        self.entrenamientoRealizado = entrenamientoRealizado
    }
}

