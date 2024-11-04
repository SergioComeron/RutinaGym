//
//  EntrenamientoEnCursoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//
import SwiftUI
import SwiftData

struct EntrenamientoEnCursoView: View {
    @Binding var entrenamientoRealizado: EntrenamientoRealizado?
    @Environment(\.modelContext) private var modelContext
    @State private var mostrandoAlertaFinalizar = false
    @AppStorage("liveactivity") var activityIdentifier: String = ""

    var body: some View {
        VStack {
            if let entrenamientoRealizado = entrenamientoRealizado,
               let entrenamientoPlanificado = entrenamientoRealizado.entrenamientoPlanificado,
               let seriesPlanificadas = entrenamientoPlanificado.series,
               !seriesPlanificadas.isEmpty {

                // Filtrar series planificadas para mostrar solo las no realizadas
                let seriesPendientes = seriesPlanificadas.filter { seriePlanificada in
                    !(entrenamientoRealizado.seriesRealizadas?.contains { $0.seriePlanificada == seriePlanificada } ?? false)
                }


                // Mostrar solo las series pendientes en el carrusel
                if !seriesPendientes.isEmpty {
                    SerieRealizadaView(
                        seriesPlanificadas: seriesPendientes,
                        entrenamientoRealizado: entrenamientoRealizado
                    )
                } else {
                    Text("Todas las series de este entrenamiento han sido completadas.")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
            } else {
                Text("No hay series planificadas para este entrenamiento")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finalizar") {
                    mostrandoAlertaFinalizar = true
                }
            }
        }
        .alert(isPresented: $mostrandoAlertaFinalizar) {
            Alert(
                title: Text("Finalizar Entrenamiento"),
                message: Text("¿Estás seguro de que deseas finalizar el entrenamiento?"),
                primaryButton: .destructive(Text("Finalizar")) {
                    finalizarEntrenamiento()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func finalizarEntrenamiento() {
        entrenamientoRealizado?.fechaFin = Date()
        entrenamientoRealizado?.finalizado = true
        eliminarLiveActivity()
        entrenamientoRealizado = nil
    }

    private func eliminarLiveActivity() {
        Task {
            await TrainingActivityUseCase.endActivity(withActivityIdentifier: activityIdentifier)
        }
    }
}
