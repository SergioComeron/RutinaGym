//
//  ResumenEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 15/10/24.
//

import SwiftUI

struct ResumenEntrenamientoView: View {
    var entrenamientoRealizado: EntrenamientoRealizado

    var body: some View {
        VStack {
            if let fechaInicio = entrenamientoRealizado.fechaInicio, let fechaFin = entrenamientoRealizado.fechaFin {
                Text("Inicio: \(fechaInicio, formatter: dateTimeFormatter) - Fin: \(fechaFin, formatter: dateTimeFormatter)")
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            if let seriesRealizadas = entrenamientoRealizado.seriesRealizadas {
                List {
                    ForEach(seriesRealizadas.sorted(by: { $0.fecha < $1.fecha })) { serieRealizada in
                        VStack(alignment: .leading) {
                            if let ejercicio = serieRealizada.seriePlanificada?.ejercicios {
                                Text(ejercicio.nombre)
                                    .font(.headline)
                            }
                            Text("Fecha de la serie: \(serieRealizada.fecha, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let peso = serieRealizada.pesoUtilizado {
                                Text("Peso: \(String(format: "%.2f", peso)) kg")
                                    .font(.body)
                            }
                            if let repeticiones = serieRealizada.repeticionesRealizadas {
                                Text("Repeticiones: \(repeticiones)")
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            } else {
                Text("No se registraron series")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Resumen de Entrenamiento")
        .padding()
    }
}

// Formato de fecha con hora
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
