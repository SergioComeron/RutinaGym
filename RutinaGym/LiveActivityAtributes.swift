//
//  LiveActivityAtributes.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 24/10/24.
//

import Foundation
import ActivityKit

struct LiveActivityAtributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var serie: Serie
        var entrenamiento: Entrenamiento
        var pesoMaximo : Double
        var resumenText: String // Nueva propiedad para el resumen

    }
}
