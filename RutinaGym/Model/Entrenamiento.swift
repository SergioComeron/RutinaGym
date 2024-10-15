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

    @Relationship(deleteRule: .cascade, inverse: \EntrenamientoRealizado.entrenamientoPlanificado)
    var entrenamientosRealizados: [EntrenamientoRealizado]? = []
    
    init(nombre: String, fecha: Date = Date(), series: [Serie] = []) {
        self.nombre = nombre
        self.fecha = fecha
        self.series = series
    }
}

extension Entrenamiento {
    var seriesResumen: [String] {
        guard let series = series else { return [] }
        var resumenArray: [String] = []

        // Ordenamos las series por fecha de creación
        let orderedSeries = series.sorted(by: { $0.fechaCreacion < $1.fechaCreacion })

        // Agrupamos las series por nombre de ejercicio y tipo de serie
        var resumenDict: [(nombreEjercicio: String, tipoSerie: TipoSerie, repeticionesArray: [Int?])] = []

        for serie in orderedSeries {
            guard let ejercicio = serie.ejercicios else {
                continue
            }
            let nombreEjercicio = ejercicio.nombre
            let repeticiones = serie.repeticiones  // repeticiones ahora es Int?
            let tipoSerie = serie.tipoSerie

            // Buscamos si ya existe una entrada para este ejercicio y tipo de serie
            if let index = resumenDict.firstIndex(where: { $0.nombreEjercicio == nombreEjercicio && $0.tipoSerie == tipoSerie }) {
                resumenDict[index].repeticionesArray.append(repeticiones)
            } else {
                resumenDict.append((nombreEjercicio: nombreEjercicio, tipoSerie: tipoSerie, repeticionesArray: [repeticiones]))
            }
        }

        // Generamos el resumen
        for (nombreEjercicio, tipoSerie, repeticionesArray) in resumenDict {
            if tipoSerie == .dropSet {
                // Para dropset, mostramos "1 dropset nombre ejercicio"
                let resumen = "1 dropset \(nombreEjercicio)"
                resumenArray.append(resumen)
            } else if tipoSerie == .alFallo {
                // Para alFallo, mostramos "cantidad x al fallo ejercicio"
                let cantidad = repeticionesArray.count
                let resumen = "\(cantidad)x al fallo \(nombreEjercicio)"
                resumenArray.append(resumen)
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

                let resumen = "\(cantidad)x\(repeticionesStr) \(nombreEjercicio)"
                resumenArray.append(resumen)
            }
        }

        return resumenArray
    }
}








