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
    @Published var resumenItemsCompletados: [UUID: Bool] = [:]
    @Published var selectedResumenItem: SeriesResumenItem?


    init(seriesPlanificadas: [Serie], entrenamientoRealizado: EntrenamientoRealizado, todasLasSeriesRealizadas: [SerieRealizada]) {
        self.seriesPlanificadas = seriesPlanificadas
        self.entrenamientoRealizado = entrenamientoRealizado
        self.todasLasSeriesRealizadas = todasLasSeriesRealizadas
        inicializarSeriesGuardadas()
        inicializarResumenItemsCompletados()
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
            // Marcar el elemento del resumen como completado
            if let resumenItem = selectedResumenItem {
                resumenItemsCompletados[resumenItem.id] = true
            }
            // Verificar si todos los elementos del resumen están completados
            if let resumenItems = entrenamientoRealizado.entrenamientoPlanificado?.seriesResumen {
                entrenamientoCompletado = resumenItems.allSatisfy { resumenItemsCompletados[$0.id] == true }
            }
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
        
        // Recalcular los elementos del resumen completados
        inicializarResumenItemsCompletados()
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
    
    func updateSeriesPlanificadas(for resumenItem: SeriesResumenItem) {
        self.seriesPlanificadas = resumenItem.series.sorted(by: { $0.fechaCreacion < $1.fechaCreacion })
        self.selectedResumenItem = resumenItem
        inicializarSeriesGuardadas()
        currentIndex = 0
    }


    func inicializarResumenItemsCompletados() {
        guard let resumenItems = entrenamientoRealizado.entrenamientoPlanificado?.seriesResumen else { return }
        for resumenItem in resumenItems {
            let seriesIds = resumenItem.series.map { $0.id }
            let seriesRealizadasIds = entrenamientoRealizado.seriesRealizadas?.compactMap { $0.seriePlanificada?.id } ?? []
            let seriesCompletadas = seriesIds.allSatisfy { seriesRealizadasIds.contains($0) }
            resumenItemsCompletados[resumenItem.id] = seriesCompletadas
            print("ResumenItem \(resumenItem.id) completado: \(seriesCompletadas)")
        }
        entrenamientoCompletado = resumenItems.allSatisfy { resumenItemsCompletados[$0.id] == true }
    }


}
