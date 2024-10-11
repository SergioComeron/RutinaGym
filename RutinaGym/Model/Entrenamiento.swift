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
        
        // Agrupamos las series por nombre de ejercicio mientras preservamos el orden
        var resumenDict: [(nombreEjercicio: String, repeticionesArray: [Int])] = []
        
        for serie in orderedSeries {
            guard let ejercicio = serie.ejercicios else {
                continue
            }
            let nombreEjercicio = ejercicio.nombre
            let repeticiones = serie.repeticiones
            
            // Buscamos si ya existe una entrada para este ejercicio
            if let index = resumenDict.firstIndex(where: { $0.nombreEjercicio == nombreEjercicio }) {
                resumenDict[index].repeticionesArray.append(repeticiones)
            } else {
                resumenDict.append((nombreEjercicio: nombreEjercicio, repeticionesArray: [repeticiones]))
            }
        }
        
        // Generamos el resumen
        for (nombreEjercicio, repeticionesArray) in resumenDict {
            let cantidad = repeticionesArray.count
            let uniqueReps = Set(repeticionesArray)
            let repeticionesStr: String
            if uniqueReps.count == 1, let rep = uniqueReps.first {
                repeticionesStr = "\(rep)"
            } else {
                repeticionesStr = repeticionesArray.map { "\($0)" }.joined(separator: ",")
            }
            let resumen = "\(cantidad)x\(repeticionesStr) \(nombreEjercicio)"
            resumenArray.append(resumen)
        }
        
        return resumenArray
    }
}






