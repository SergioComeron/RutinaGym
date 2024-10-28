//
//  Untitled.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftData
import Foundation

@Model
final class Entrenamiento: Identifiable, Codable {
    var nombre: String = ""
    var fecha: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Serie.entrenamiento)
    var series: [Serie]? = []

    @Relationship(deleteRule: .cascade, inverse: \EntrenamientoRealizado.entrenamientoPlanificado)
    var entrenamientosRealizados: [EntrenamientoRealizado]? = []

    init(nombre: String, fecha: Date = Date(), series: [Serie] = []) {
        self.nombre = nombre
        self.fecha = fecha
        self.series = series
    }

    enum CodingKeys: String, CodingKey {
        case nombre
        case fecha
        // Excluimos 'series' y 'entrenamientosRealizados' si no conforman a Codable
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nombre, forKey: .nombre)
        try container.encode(fecha, forKey: .fecha)
        // No codificamos 'series' ni 'entrenamientosRealizados' aquí
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nombre = try container.decode(String.self, forKey: .nombre)
        fecha = try container.decode(Date.self, forKey: .fecha)
        // Inicializamos las propiedades no codificadas
        series = []
        entrenamientosRealizados = []
    }
}


extension Entrenamiento {
    var seriesResumen: [SeriesResumenItem] {
        guard let series = series else { return [] }
        var resumenArray: [SeriesResumenItem] = []

        // Ordenamos las series por fecha de creación
        let orderedSeries = series.sorted(by: { $0.fechaCreacion < $1.fechaCreacion })

        // Mantenemos un array de resumenItems para preservar el orden
        for serie in orderedSeries {
            guard let ejercicio = serie.ejercicios else {
                continue
            }
            let nombreEjercicio = ejercicio.nombre
            let tipoSerie = serie.tipoSerie

            // Buscamos si ya existe un resumenItem para este ejercicio y tipo de serie
            if let index = resumenArray.firstIndex(where: { $0.nombreEjercicio == nombreEjercicio && $0.tipoSerie == tipoSerie }) {
                // Si existe, añadimos la serie al resumenItem existente
                var resumenItem = resumenArray[index]
                resumenItem.repeticionesArray.append(serie.repeticiones)
                resumenItem.series.append(serie)
                resumenArray[index] = resumenItem
            } else {
                // Si no existe, creamos un nuevo resumenItem
                let resumenItem = SeriesResumenItem(
                    nombreEjercicio: nombreEjercicio,
                    tipoSerie: tipoSerie,
                    resumen: "", // Lo actualizaremos después
                    repeticionesArray: [serie.repeticiones],
                    series: [serie]
                )
                resumenArray.append(resumenItem)
            }
        }

        // Ahora generamos el resumen para cada resumenItem
        for index in 0..<resumenArray.count {
            var resumenItem = resumenArray[index]
            let nombreEjercicio = resumenItem.nombreEjercicio
            let tipoSerie = resumenItem.tipoSerie
            let repeticionesArray = resumenItem.repeticionesArray

            var resumenText = ""

            if tipoSerie == .dropSet {
                // Para dropset, mostramos "1x dropset nombre ejercicio"
                resumenText = "1x dropset \(nombreEjercicio)"
            } else if tipoSerie == .alFallo {
                // Para alFallo, mostramos "cantidad x al fallo ejercicio"
                let cantidad = repeticionesArray.count
                resumenText = "\(cantidad)x al fallo \(nombreEjercicio)"
            } else {
                let cantidad = repeticionesArray.count

                // Filtramos las repeticiones no nulas
                let nonNilReps = repeticionesArray.compactMap { $0 }
                let repeticionesStr: String

                if nonNilReps.isEmpty {
                    // Si no hay repeticiones registradas, usamos un signo de interrogación
                    repeticionesStr = "?"
                } else {
                    let uniqueReps = Set(nonNilReps)
                    if uniqueReps.count == 1, let rep = uniqueReps.first {
                        repeticionesStr = "\(rep)"
                    } else {
                        repeticionesStr = nonNilReps.map { "\($0)" }.joined(separator: ",")
                    }
                }

                resumenText = "\(cantidad)x\(repeticionesStr) \(nombreEjercicio)"
            }

            resumenItem.resumen = resumenText
            resumenArray[index] = resumenItem
        }

        return resumenArray
    }
}




