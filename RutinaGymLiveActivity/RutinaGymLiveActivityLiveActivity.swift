//
//  RutinaGymLiveActivityLiveActivity.swift
//  RutinaGymLiveActivity
//
//  Created by Sergio Comerón Sánchez-Pani on 18/10/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

@main
struct RutinaGymLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAtributes.self) { context in
            VStack(alignment: .leading, spacing: 12) {
                // Mostrar el resumen correspondiente en la parte superior
                Text(context.state.resumenText)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 4)
                
                // Nombre del ejercicio en un estilo destacado
                if let ejercicio = context.state.serie.ejercicios {
                    Text(ejercicio.nombre)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                }
                
                // Sección de detalles en un HStack
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repeticiones")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(context.state.serie.repeticiones ?? 0)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Tipo de Serie")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.state.serie.tipoSerie.rawValue.capitalized)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Peso Máximo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(context.state.pesoMaximo, specifier: "%.2f") kg")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        } dynamicIsland: { context in
            DynamicIsland {
                // Región principal izquierda: repeticiones y series
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repeticiones")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(context.state.serie.repeticiones ?? 0)")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 8)
                }
                
                // Región principal derecha: tipo de serie
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Tipo de Serie")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(context.state.serie.tipoSerie.rawValue.capitalized)")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 8)
                }

                // Región inferior: información del entrenamiento y seriesResumen
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center, spacing: 6) {
                        // Nombre del entrenamiento
                        Text(context.state.entrenamiento.nombre)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.primary)
                        
                        if let ejercicio = context.state.serie.ejercicios {
                            Text(ejercicio.nombre)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            } compactLeading: {
                if let ejercicio = context.state.serie.ejercicios {
                    Text(ejercicio.nombre)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.primary)
                }
            } compactTrailing: {
                Text("\(context.state.serie.repeticiones ?? 0)")
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)
                
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.green)
            }
            .widgetURL(URL(string: "http://sergiocomeron.com"))

        }
        .supplementalActivityFamilies([.small, .medium])
    }
}

extension LiveActivityAtributes {
    fileprivate static var preview: LiveActivityAtributes {
        LiveActivityAtributes()
    }
}

#Preview("Live activity", as: .dynamicIsland(.expanded), using: LiveActivityAtributes.preview) {
    RutinaGymLiveActivityLiveActivity()
} contentStates: {
    LiveActivityAtributes.ContentState(
        serie: Serie(repeticiones: 12,
                     descripcion: "",
                     ejercicios: Ejercicio(id: 999,
                                           nombre: "Press Plano máquina",
                                           variable: "",
                                           descripcion: "descripción",
                                           grupoMuscular: .abdomen),
                     tipoSerie: .normal,
                     observaciones: ""),
        entrenamiento: Entrenamiento(nombre: "nombre entrenamiento"), pesoMaximo: 15.0, resumenText: "3 x 15 Press plano máquina")
}



