//
//  DetalleEntrenamientoViewWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI

struct DetalleEntrenamientoViewWatch: View {
    var entrenamiento: Entrenamiento
    
    var body: some View {
        List {
            Section(header: Text("Series")) {
                if let series = entrenamiento.series, !series.isEmpty {
                    ForEach(series) { serie in
                        VStack(alignment: .leading) {
                            if let ejercicio = serie.ejercicios {
                                Text(ejercicio.nombre)
                                    .font(.headline)
                            } else {
                                Text("Ejercicio no disponible")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            Text("Reps: \(serie.repeticiones)")
                                .font(.caption)
                            Text("Tipo: \(serie.tipoSerie.rawValue)")
                                .font(.caption2)
                        }
                    }
                } else {
                    Text("No hay series para este entrenamiento")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle(entrenamiento.nombre)
    }
}

