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

    var body: some View {
        VStack {
            if let entrenamientoRealizado = entrenamientoRealizado,
               let entrenamientoPlanificado = entrenamientoRealizado.entrenamientoPlanificado,
               let seriesPlanificadas = entrenamientoPlanificado.series,
               !seriesPlanificadas.isEmpty {

                // Mostrar el carrusel de series planificadas usando SerieRealizadaView
                SerieRealizadaView(
                    seriesPlanificadas: seriesPlanificadas,
                    entrenamientoRealizado: entrenamientoRealizado
                )
            } else {
                Text("No hay series planificadas para este entrenamiento")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
        }
//        .navigationTitle("Entrenamiento en Curso")
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
        // Guarda el contexto si es necesario
        // try? modelContext.save()
        entrenamientoRealizado = nil
    }
}

