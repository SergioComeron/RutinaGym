//
//  SerieRealizadaViweWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//


import SwiftData
import SwiftUI
import WatchKit

import SwiftUI
import WatchKit

struct SerieRealizadaViewWatch: View {
    var seriesPlanificadas: [Serie]
    @Bindable var entrenamientoRealizado: EntrenamientoRealizado
    @State private var currentIndex = 0
    @State private var pesoUtilizado: Double = 0.0
    @State private var repeticionesRealizadas: Int = 0
    @Environment(\.modelContext) private var modelContext
    @State private var seriesGuardadas: [Int: Bool] = [:]
    @Query private var todasLasSeriesRealizadas: [SerieRealizada]
    @State private var entrenamientoCompletado = false
    @Environment(\.colorScheme) var colorScheme
    @State private var crownValue: Double = 0.0

    var body: some View {
        VStack {
            if entrenamientoCompletado {
                Text("¡Entrenamiento completado!")
                    .font(.headline)
                    .foregroundColor(.green)
            } else if !seriesPlanificadas.isEmpty {
                let seriePlanificada = seriesPlanificadas[currentIndex]

                VStack {
                    Text(seriePlanificada.ejercicios?.nombre ?? "Sin nombre")
                        .font(.headline)

                    Text("Tipo de Serie: \(seriePlanificada.tipoSerie.rawValue.capitalized)")
                        .font(.footnote)

                    Text("Reps planificadas: \(seriePlanificada.repeticiones ?? 0)")
                        .font(.footnote)

                    if let pesoMaximo = pesoMaximoParaEjercicio(seriePlanificada.ejercicios?.nombre) {
                        Text("Peso máx.: \(pesoMaximo, specifier: "%.2f") kg")
                            .font(.footnote)
                            .foregroundColor(.green)
                    }

                    // Usamos la corona digital para ajustar el peso
                    VStack {
                        Text("Peso: \(pesoUtilizado, specifier: "%.2f") kg")
                            .font(.footnote)
                        
                        HStack {
                            Button(action: {
                                ajustarPeso(-0.5)
                            }) {
                                Image(systemName: "minus.circle")
                            }
//                            .buttonStyle(.bordered)

                            Button(action: {
                                ajustarPeso(0.5)
                            }) {
                                Image(systemName: "plus.circle")
                            }
//                            .buttonStyle(.bordered)
                        }
                        
//                        .padding()

                        Text("Reps: \(repeticionesRealizadas)")
                            .font(.footnote)

                        HStack {
                            Button(action: {
                                ajustarRepeticiones(-1)
                            }) {
                                Image(systemName: "minus.circle")
                            }
//                            .buttonStyle(.bordered)

                            Button(action: {
                                ajustarRepeticiones(1)
                            }) {
                                Image(systemName: "plus.circle")
                            }
//                            .buttonStyle(.bordered)
                        }
//                        .padding()
                    }

                    HStack {
                        Button("Anterior") {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            }
                        }
                        Button("Siguiente") {
                            if currentIndex < seriesPlanificadas.count - 1 {
                                currentIndex += 1
                            }
                        }
                    }
                    .padding()

                    Button("Guardar") {
                        guardarSerie(seriePlanificada: seriePlanificada, index: currentIndex)
                    }
                    .disabled(seriesGuardadas[currentIndex] == true)
                }
            } else {
                Text("No hay más series")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
        }
        .onAppear {
            inicializarSeriesGuardadas()
        }
        .focusable(true)
        .digitalCrownRotation($crownValue, from: 0, through: 100, by: 1, sensitivity: .low, isContinuous: false)
    }

    private func ajustarPeso(_ cantidad: Double) {
        pesoUtilizado = max(0, pesoUtilizado + cantidad)
    }

    private func ajustarRepeticiones(_ cantidad: Int) {
        repeticionesRealizadas = max(0, repeticionesRealizadas + cantidad)
    }

    private func guardarSerie(seriePlanificada: Serie, index: Int) {
        let nuevaSerieRealizada = SerieRealizada(
            seriePlanificada: seriePlanificada,
            pesoUtilizado: pesoUtilizado,
            repeticionesRealizadas: repeticionesRealizadas,
            observaciones: "",
            entrenamientoRealizado: entrenamientoRealizado
        )

        if entrenamientoRealizado.seriesRealizadas == nil {
            entrenamientoRealizado.seriesRealizadas = []
        }

        entrenamientoRealizado.seriesRealizadas?.append(nuevaSerieRealizada)
        modelContext.insert(nuevaSerieRealizada)

        seriesGuardadas[index] = true

        let totalSeriesPlanificadas = seriesPlanificadas.count
        let totalSeriesGuardadas = seriesGuardadas.filter { $0.value == true }.count

        if totalSeriesGuardadas == totalSeriesPlanificadas {
            entrenamientoCompletado = true
        }

        do {
            try modelContext.save()
        } catch {
            print("Error guardando el contexto: \(error)")
        }
    }

    private func pesoMaximoParaEjercicio(_ nombreEjercicio: String?) -> Double? {
        guard let nombreEjercicio = nombreEjercicio else { return nil }
        let seriesFiltradas = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == nombreEjercicio }
        return seriesFiltradas.map { $0.pesoUtilizado ?? 0 }.max()
    }

    private func inicializarSeriesGuardadas() {
        for index in 0..<seriesPlanificadas.count {
            seriesGuardadas[index] = false
        }
    }
}

//// DigitalCrownRotating es un view personalizado para manejar la corona digital
//struct DigitalCrownRotating: View {
//    @Binding var value: Double
//    
//    var body: some View {
//        Text("\(value, specifier: "%.2f") kg")
//            .focusable(true)
//            .digitalCrownRotation($value, from: 0, through: 200, by: 0.5, sensitivity: .medium, isContinuous: false)
//    }
//}
//
//
//
//struct DigitalCrownRotatingInt: View {
//    @Binding var value: Int
//
//    var body: some View {
//        Text("\(value) reps")
//            .focusable(true)
//            .digitalCrownRotation(
//                Binding(
//                    get: { Double(value) },
//                    set: { value = Int($0) }
//                ),
//                from: 0, through: 100, by: 1, sensitivity: .medium, isContinuous: false
//            )
//    }
//}
//

