//
//  DetalleEntrenamientoViewWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI
import SwiftData

struct DetalleEntrenamientoViewWatch: View {
    var entrenamiento: Entrenamiento
    @Environment(\.modelContext) private var modelContext

    @State private var mostrarSeriesDetalladas = false
    @State private var entrenamientoEnCurso: EntrenamientoRealizado?
    @State private var mostrandoAlertaFinalizar = false

    @Query(sort: \EntrenamientoRealizado.fechaInicio, order: .reverse)
    var entrenamientosRealizados: [EntrenamientoRealizado]

    private var entrenamientosRealizadosEntrenamiento: [EntrenamientoRealizado] {
        entrenamientosRealizados.filter { $0.entrenamientoPlanificado == entrenamiento }
    }

    var body: some View {
        VStack {
            if let entrenamientoEnCurso = entrenamientoEnCurso {
                EntrenamientoEnCursoViewWatch(entrenamientoRealizado: Binding(get: { entrenamientoEnCurso }, set: { self.entrenamientoEnCurso = $0 }))
            } else {
                List {
                    Section(header: Text("Detalles")) {
                        Text("Nombre: \(entrenamiento.nombre)")
                            .font(.headline)
                    }

                }
                .navigationTitle("Entrenamiento")
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

                Button(action: {
                    iniciarEntrenamiento()
                }) {
                    Text("Iniciar Entrenamiento")
                        .font(.headline)
                        .padding()
                }
                .padding()
            }
        }
    }

    private func iniciarEntrenamiento() {
        let nuevoEntrenamientoRealizado = EntrenamientoRealizado(entrenamientoPlanificado: entrenamiento)
        entrenamientoEnCurso = nuevoEntrenamientoRealizado
        modelContext.insert(nuevoEntrenamientoRealizado)
    }

    private func finalizarEntrenamiento() {
        entrenamientoEnCurso?.fechaFin = Date()
        entrenamientoEnCurso = nil
        // modelContext.saveOrRollback() // Guarda el contexto de datos
    }
}
