//
//  EntrenamientoEnCursoViewWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//

import SwiftUI

struct EntrenamientoEnCursoViewWatch: View {
    @Binding var entrenamientoRealizado: EntrenamientoRealizado?
    @Environment(\.modelContext) private var modelContext
    @State private var mostrandoAlertaFinalizar = false

    var body: some View {
        VStack {
            if let entrenamientoRealizado = entrenamientoRealizado,
               let entrenamientoPlanificado = entrenamientoRealizado.entrenamientoPlanificado,
               let seriesPlanificadas = entrenamientoPlanificado.series,
               !seriesPlanificadas.isEmpty {

                // Cargar directamente SerieRealizadaViewWatch
                SerieRealizadaViewWatch(
                    seriesPlanificadas: seriesPlanificadas,
                    entrenamientoRealizado: entrenamientoRealizado
                )
            } else {
                Text("No hay series planificadas")
                    .foregroundColor(.gray)
                    .font(.headline)
            }

            Button(action: {
                mostrandoAlertaFinalizar = true
            }) {
                Text("Finalizar")
                    .font(.headline)
                    .padding()
                    .padding(.top)
            }
        }
//        .navigationTitle("Entrenamiento en Curso")
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
