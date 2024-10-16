//
//  EntrenamientoEnCursoViewWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//

import SwiftUI
import SwiftData

struct EntrenamientoEnCursoViewWatch: View {
    @Binding var entrenamientoRealizado: EntrenamientoRealizado?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var mostrandoAlertaFinalizar = false

    var body: some View {
        NavigationView {
            VStack {
                if let entrenamientoRealizado = entrenamientoRealizado,
                   let entrenamientoPlanificado = entrenamientoRealizado.entrenamientoPlanificado,
                   let seriesPlanificadas = entrenamientoPlanificado.series,
                   !seriesPlanificadas.isEmpty {

                    // Lista de series planificadas
                    List(seriesPlanificadas, id: \.id) { serie in
                        NavigationLink(destination: SerieRealizadaViewWatch(seriePlanificada: serie, entrenamientoRealizado: entrenamientoRealizado)) {
                            VStack(alignment: .leading) {
                                Text(serie.ejercicios?.nombre ?? "Ejercicio sin nombre")
                                    .font(.headline)
                                Text("Reps: \(serie.repeticiones ?? 0)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    Text("No hay series planificadas para este entrenamiento")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
            }
            .navigationTitle("Entrenamiento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
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

        .navigationTitle("Entrenamiento")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
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
        // modelContext.saveOrRollback() // Utiliza una función personalizada para guardar o descartar cambios
        entrenamientoRealizado = nil
        dismiss() // Descartar la vista actual y volver a la anterior
    }
}
