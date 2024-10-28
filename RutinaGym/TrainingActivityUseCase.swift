//
//  TrainingActivityUseCase.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 24/10/24.
//

import Foundation
import ActivityKit

final class TrainingActivityUseCase {
    
    static func startActivity(serie: Serie, entrenamiento: Entrenamiento, pesoMaximo: Double) throws -> String {
        print("Iniciando live activity desde dentro funcion")
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return "" }

        let initialState = LiveActivityAtributes.ContentState(serie: serie, entrenamiento: entrenamiento, pesoMaximo: pesoMaximo, resumenText: "")
        
        let futureDate: Date = .now + 3600

        let activityContent = ActivityContent(state: initialState,
                                              staleDate: futureDate)
        
        let attributes = LiveActivityAtributes()
        do {
            let activity = try Activity.request(attributes: attributes,
                                                content: activityContent,
                                                pushType: nil)
            return activity.id
        } catch {
            throw error
        }
    }
    
    static func updateActivity(activityIdentifier: String, serie: Serie, pesoMaximo: Double) async {
        if let entrenamiento = serie.entrenamiento {
            // Obtener el resumen que corresponde a la serie actual
            if let resumenItem = entrenamiento.seriesResumen.first(where: { $0.series.contains(where: { $0 == serie }) }) {
                let resumenText = resumenItem.resumen
                
                let updatedContentState = LiveActivityAtributes.ContentState(
                    serie: serie,
                    entrenamiento: entrenamiento,
                    pesoMaximo: pesoMaximo,
                    resumenText: resumenText
                )
                
                let activity = Activity<LiveActivityAtributes>.activities.first(where: { $0.id == activityIdentifier })
                
                let activityContent = ActivityContent(state: updatedContentState, staleDate: .now + 3600)
                await activity?.update(activityContent)
            } else {
                print("No se encontró un resumen para la serie actual")
            }
        }
    }
    
    static func endActivity(withActivityIdentifier activityIdentifier: String) async {
        let value = Activity<LiveActivityAtributes>.activities.first(where: { $0.id == activityIdentifier })
        await value?.end(nil)
    }
    
}


