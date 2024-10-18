//
//  ResumenEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 15/10/24.
//

import SwiftUI
import SwiftData

struct ResumenEntrenamientoView: View {
    var entrenamientoRealizado: EntrenamientoRealizado
    
    @Query private var todasLasSeriesRealizadas: [SerieRealizada] // Utiliza Query para obtener las series

    // Agrupamos las series realizadas por ejercicio y obtenemos los pesos usados
    var seriesPorEjercicio: [String: [SerieRealizada]] {
        Dictionary(grouping: entrenamientoRealizado.seriesRealizadas ?? [], by: { $0.seriePlanificada?.ejercicios?.nombre ?? "Desconocido" })
    }
    
    // Función que calcula el peso máximo realizado a lo largo del tiempo para un ejercicio específico
    func obtenerPesoMaximoGlobal(ejercicio: String) -> Double {
        let seriesDeEjercicio = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == ejercicio }
        let pesoMaximo = seriesDeEjercicio.compactMap { $0.pesoUtilizado }.max() ?? 0.0
        return pesoMaximo
    }

    var body: some View {
        VStack {
            if let fechaInicio = entrenamientoRealizado.fechaInicio, let fechaFin = entrenamientoRealizado.fechaFin {
                Text("Inicio: \(fechaInicio, formatter: dateTimeFormatter) - Fin: \(fechaFin, formatter: dateTimeFormatter)")
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            
            List {
                ForEach(seriesPorEjercicio.keys.sorted(), id: \.self) { ejercicio in
                    VStack(alignment: .leading) {
                        Text(ejercicio)
                            .font(.headline)
                        
                        // Obtenemos el peso máximo a lo largo del tiempo para este ejercicio
                        let pesoMaximoGlobal = obtenerPesoMaximoGlobal(ejercicio: ejercicio)
                        
                        // Obtenemos las series realizadas para este ejercicio
                        if let series = seriesPorEjercicio[ejercicio] {
                            ForEach(series) { serie in
                                HStack {
                                    if let peso = serie.pesoUtilizado {
                                        // Si el peso de la serie es el máximo a lo largo del tiempo, agregamos el símbolo
                                        Text("Peso: \(String(format: "%.2f", peso)) kg")
                                            .font(.body)
                                            .foregroundColor(peso == pesoMaximoGlobal ? .red : .primary)
                                        
                                        if peso == pesoMaximoGlobal {
                                            Text("⭐️") // Símbolo para marcar la serie con el peso máximo global
                                        }
                                    }
                                    
                                    if let repeticiones = serie.repeticionesRealizadas {
                                        Text("Repeticiones: \(repeticiones)")
                                            .font(.body)
                                            .padding(.leading, 10)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Resumen de Entrenamiento")
        .padding()
    }

    // Formato de fecha con hora
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
