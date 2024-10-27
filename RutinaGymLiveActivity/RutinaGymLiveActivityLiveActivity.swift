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
            VStack {
//                Text("\(context.state.entrenamiento.nombre)")
                if let ejercicio = context.state.serie.ejercicios {
                    Text("\(ejercicio.nombre)")
                }
                
                HStack {
                    Text("Rep: \(context.state.serie.repeticiones ?? 0)")
                    Text("x \(context.state.serie.tipoSerie.rawValue.capitalized)")
                }
                Text("Peso \(context.state.pesoMaximo, specifier: "%.2f")")
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack{
                        Text("3x15")
                    }
                    .padding(.leading)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack{
                        Text("DropSet")
                    }
                    .padding(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.state.entrenamiento.nombre)")
                    if context.state.entrenamiento.seriesResumen.isEmpty {
                        Text("No hay series para este entrenamiento")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(context.state.entrenamiento.seriesResumen, id: \.self) { resumen in
                            Text(resumen)
                        }
                    }
                }
            } compactLeading: {
                Text("Press pecho banco plano")
            } compactTrailing: {

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
                                           nombre: "Nombre ejercicio",
                                           variable: "",
                                           descripcion: "descripción",
                                           grupoMuscular: .abdomen),
                     tipoSerie: .normal,
                     observaciones: ""),
        entrenamiento: Entrenamiento(nombre: "nombre entrenamiento"), pesoMaximo: 15.0)
}



