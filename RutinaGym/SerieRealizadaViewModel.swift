//
//  SerieRealizadaViewModel.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 27/10/24.
//

import SwiftUI
import SwiftData

class SerieRealizadaViewModel: ObservableObject {
    @Environment(\.modelContext) private var modelContext

    @Published var seriesPlanificadas: [Serie]
    @Published var entrenamientoRealizado: EntrenamientoRealizado
    @Published var pesoUtilizado: String = ""
    @Published var repeticionesRealizadas: String = ""
    @Published var seriesGuardadas: [Int: Bool] = [:]
    @Published var currentIndex: Int = 0
    @Published var entrenamientoCompletado: Bool = false
    @Published var todasLasSeriesRealizadas: [SerieRealizada]

    init(seriesPlanificadas: [Serie], entrenamientoRealizado: EntrenamientoRealizado, todasLasSeriesRealizadas: [SerieRealizada]) {
        self.seriesPlanificadas = seriesPlanificadas
        self.entrenamientoRealizado = entrenamientoRealizado
        self.todasLasSeriesRealizadas = todasLasSeriesRealizadas
        inicializarSeriesGuardadas()
    }

    func guardarSerie(seriePlanificada: Serie, index: Int, modelContext: ModelContext) {
        let nuevaSerieRealizada = SerieRealizada(
            seriePlanificada: seriePlanificada,
            pesoUtilizado: Double(pesoUtilizado),
            repeticionesRealizadas: Int(repeticionesRealizadas),
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
        } else {
            if currentIndex < seriesPlanificadas.count - 1 {
                withAnimation {
                    currentIndex += 1
                }
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Error guardando el contexto: \(error)")
        }
    }

    func ajustarPeso(_ cantidad: Double) {
        if let pesoActual = Double(pesoUtilizado) {
            let nuevoPeso = max(0, pesoActual + cantidad)
            pesoUtilizado = String(format: "%.2f", nuevoPeso)
        }
    }

    func ajustarRepeticiones(_ cantidad: Int) {
        if let repeticionesActuales = Int(repeticionesRealizadas) {
            let nuevasRepeticiones = max(0, repeticionesActuales + cantidad)
            repeticionesRealizadas = "\(nuevasRepeticiones)"
        }
    }

    func inicializarSeriesGuardadas() {
        for index in 0..<seriesPlanificadas.count {
            seriesGuardadas[index] = false
        }
    }

    func pesoMaximoParaEjercicio(_ nombreEjercicio: String?) -> Double? {
        guard let nombreEjercicio = nombreEjercicio else { return nil }
        let seriesFiltradas = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == nombreEjercicio }
        return seriesFiltradas.map { $0.pesoUtilizado ?? 0 }.max()
    }
}
