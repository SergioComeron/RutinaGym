//
//  DetalleEntrenamientoViewWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI

struct DetalleEntrenamientoViewWatch: View {
    var entrenamiento: Entrenamiento
    @State private var mostrandoEntrenamientoEnCurso = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
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
                                Text("Reps: \(serie.repeticiones ?? 0)")
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
            .listStyle(CarouselListStyle())
            .navigationTitle(entrenamiento.nombre)
            
            // Botón para Iniciar el Entrenamiento
            Button(action: {
                mostrandoEntrenamientoEnCurso = true
            }) {
                Text("Iniciar Entrenamiento")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BorderedButtonStyle())
            .padding()
            .sheet(isPresented: $mostrandoEntrenamientoEnCurso) {
                EntrenamientoEnCursoViewWatch(entrenamientoRealizado: .constant(EntrenamientoRealizado(entrenamientoPlanificado: entrenamiento)))
            }
        }
    }
}


