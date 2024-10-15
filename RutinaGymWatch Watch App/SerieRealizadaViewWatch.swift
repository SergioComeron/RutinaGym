//
//  SerieRealizadaViweWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//

import SwiftUI
import Charts
import SwiftData

struct SerieRealizadaViewWatch: View {
    var seriePlanificada: Serie
    @Bindable var entrenamientoRealizado: EntrenamientoRealizado
    @State private var pesoUtilizado: String = ""
    @State private var repeticionesRealizadas: String = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var todasLasSeriesRealizadas: [SerieRealizada] // Utiliza Query para obtener las series

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(seriePlanificada.ejercicios?.nombre ?? "Ejercicio sin nombre")
                    .font(.title3)
                    .padding(.top)

                Text("Tipo de Serie: \(seriePlanificada.tipoSerie.rawValue.capitalized)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("Reps planificadas: \(seriePlanificada.repeticiones ?? 0)")
                    .font(.body)

                // Campos de texto sin teclado específico
                TextField("Peso utilizado", text: $pesoUtilizado)

                TextField("Reps realizadas", text: $repeticionesRealizadas)

                Button(action: {
                    guardarSerie()
                }) {
                    Text("Guardar Serie")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(entrenamientoRealizado.seriesRealizadas?.contains { $0.seriePlanificada?.id == seriePlanificada.id } ?? false)

                // Gráfico de los pesos registrados en todas las series del mismo ejercicio
                if let ejercicio = seriePlanificada.ejercicios {
                    Chart {
                        let seriesFiltradas = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios == ejercicio }
                        ForEach(seriesFiltradas) { serieRealizada in
                            if let peso = serieRealizada.pesoUtilizado {
                                PointMark(
                                    x: .value("Fecha", serieRealizada.fecha),
                                    y: .value("Peso", peso)
                                )
                                .symbol(Circle())
                            }
                        }
                    }
                    .frame(height: 100)
                    .padding(.top, 5)
                }
            }
            .padding()
        }
    }

    private func guardarSerie() {
        // Crear una nueva instancia de SerieRealizada
        let nuevaSerieRealizada = SerieRealizada(
            seriePlanificada: seriePlanificada,
            pesoUtilizado: Double(pesoUtilizado),
            repeticionesRealizadas: Int(repeticionesRealizadas),
            observaciones: "",
            entrenamientoRealizado: entrenamientoRealizado
        )
        if var seriesRealizadas = seriePlanificada.seriesRealizadas {
            seriesRealizadas.append(nuevaSerieRealizada)
        }
        modelContext.insert(nuevaSerieRealizada)

        // Guardar contexto si es necesario
//        modelContext.saveOrRollback()
    }
}

