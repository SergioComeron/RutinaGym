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
final class Serie: Identifiable, Codable {
    var repeticiones: Int? = 15
    var descripcion: String?
    var ejercicios: Ejercicio?
    var tipoSerie: TipoSerie = TipoSerie.subiendoPeso
    var observaciones: String?
    var fechaCreacion: Date = Date()

    var entrenamiento: Entrenamiento?
    @Relationship(deleteRule: .cascade, inverse: \SerieRealizada.seriePlanificada)
    var seriesRealizadas: [SerieRealizada]? = []

    init(repeticiones: Int?, descripcion: String?, ejercicios: Ejercicio?, tipoSerie: TipoSerie, observaciones: String?) {
        self.repeticiones = repeticiones
        self.descripcion = descripcion
        self.ejercicios = ejercicios
        self.tipoSerie = tipoSerie
        self.observaciones = observaciones
        self.fechaCreacion = Date()
    }

    enum CodingKeys: String, CodingKey {
        case repeticiones
        case descripcion
        case ejercicios
        case tipoSerie
        case observaciones
        case fechaCreacion
        // Excluimos las propiedades no codificables o no necesarias
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(repeticiones, forKey: .repeticiones)
        try container.encode(descripcion, forKey: .descripcion)
        try container.encode(ejercicios, forKey: .ejercicios)
        try container.encode(tipoSerie, forKey: .tipoSerie)
        try container.encode(observaciones, forKey: .observaciones)
        try container.encode(fechaCreacion, forKey: .fechaCreacion)
    }

    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            repeticiones = try container.decodeIfPresent(Int.self, forKey: .repeticiones)
            descripcion = try container.decodeIfPresent(String.self, forKey: .descripcion)
            ejercicios = try container.decodeIfPresent(Ejercicio.self, forKey: .ejercicios)
            tipoSerie = try container.decode(TipoSerie.self, forKey: .tipoSerie)
            observaciones = try container.decodeIfPresent(String.self, forKey: .observaciones)
            fechaCreacion = try container.decode(Date.self, forKey: .fechaCreacion)
            // Inicializamos propiedades no codificables o necesarias en tiempo de ejecución
            entrenamiento = nil
            seriesRealizadas = []
        }
}
