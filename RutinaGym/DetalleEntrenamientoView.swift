//
//  DetalleEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI
import SwiftData

struct DetalleEntrenamientoView: View {
    var entrenamiento: Entrenamiento
    @Environment(\.modelContext) private var modelContext
    @AppStorage("liveactivity") var activityIdentifier: String = ""

    @State private var mostrarEditarEntrenamiento = false
    @State private var mostrarSeriesDetalladas = false
    @State private var entrenamientoEnCurso: EntrenamientoRealizado?
    @State private var mostrandoAlertaFinalizar = false
    @State private var entrenamientoSeleccionado: EntrenamientoRealizado?

    @Query(sort: \EntrenamientoRealizado.fechaInicio, order: .reverse)
    var entrenamientosRealizados: [EntrenamientoRealizado]
    
    @Query private var todasLasSeriesRealizadas: [SerieRealizada]

    private var entrenamientosRealizadosEntrenamiento: [EntrenamientoRealizado] {
        entrenamientosRealizados.filter { $0.entrenamientoPlanificado == entrenamiento }
    }

    private var entrenamientosNoFinalizados: [EntrenamientoRealizado] {
        entrenamientosRealizadosEntrenamiento.filter { !$0.finalizado }
    }

    private func obtenerPesoMaximoGlobal(ejercicio: String) -> Double {
        let seriesDeEjercicio = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == ejercicio }
        return seriesDeEjercicio.compactMap { $0.pesoUtilizado }.max() ?? 0.0
    }

    private func tienePesoMaximo(entrenamientoRealizado: EntrenamientoRealizado) -> Bool {
        for serieRealizada in entrenamientoRealizado.seriesRealizadas ?? [] {
            if let ejercicio = serieRealizada.seriePlanificada?.ejercicios?.nombre,
               let peso = serieRealizada.pesoUtilizado {
                let pesoMaximo = obtenerPesoMaximoGlobal(ejercicio: ejercicio)
                if peso == pesoMaximo {
                    return true
                }
            }
        }
        return false
    }

    var body: some View {
        VStack {
            if let entrenamientoEnCurso = entrenamientoEnCurso {
                EntrenamientoEnCursoView(entrenamientoRealizado: Binding(get: { entrenamientoEnCurso }, set: { self.entrenamientoEnCurso = $0 }))
            } else {
                List {
                    Section(header: Text("Entrenamientos No Finalizados")) {
                        if entrenamientosNoFinalizados.isEmpty {
                            Text("No hay entrenamientos en curso")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(entrenamientosNoFinalizados) { entrenamientoRealizado in
                                Button(action: {
                                    entrenamientoEnCurso = entrenamientoRealizado
                                }) {
                                    if let fechaInicio = entrenamientoRealizado.fechaInicio {
                                        Text("Fecha: \(fechaInicio, formatter: dateFormatter)")
                                            .font(.headline)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }

                    Section(header: Text("Detalles")) {
                        Text("Nombre: \(entrenamiento.nombre)")
                        Text("Fecha: \(entrenamiento.fecha, formatter: dateFormatter)")
                    }

                    Section(header: Text("Resumen de Series")) {
                        if entrenamiento.seriesResumen.isEmpty {
                            Text("No hay series para este entrenamiento")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(entrenamiento.seriesResumen) { resumenItem in
                                Text(resumenItem.resumen)
                            }
                        }
                    }

                    Section(header: Text("Entrenamientos Realizados")) {
                        if entrenamientosRealizadosEntrenamiento.isEmpty {
                            Text("No se han realizado entrenamientos aún")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(entrenamientosRealizadosEntrenamiento) { entrenamientoRealizado in
                                NavigationLink(destination: ResumenEntrenamientoView(entrenamientoRealizado: entrenamientoRealizado)) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            if let fechaInicio = entrenamientoRealizado.fechaInicio {
                                                Text("Fecha: \(fechaInicio, formatter: dateFormatter)")
                                                    .font(.headline)
                                            }
                                            if tienePesoMaximo(entrenamientoRealizado: entrenamientoRealizado) {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .onDelete(perform: eliminarEntrenamientos)
                        }
                    }
                }
                .navigationTitle(entrenamiento.nombre)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                .sheet(isPresented: $mostrarEditarEntrenamiento) {
                    EditarEntrenamientoView(entrenamiento: entrenamiento)
                }

                Button(action: {
                    iniciarEntrenamiento()
                }) {
                    Text("Iniciar Entrenamiento")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }

    private func iniciarEntrenamiento() {
        let nuevoEntrenamientoRealizado = EntrenamientoRealizado(entrenamientoPlanificado: entrenamiento)
        entrenamientoEnCurso = nuevoEntrenamientoRealizado
        modelContext.insert(nuevoEntrenamientoRealizado)
        
        if let serie = entrenamiento.series?.sorted(by: { $0.fechaCreacion < $1.fechaCreacion }).first {
            do {
                activityIdentifier = try TrainingActivityUseCase.startActivity(serie: serie, entrenamiento: entrenamiento, pesoMaximo: 0)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func eliminarEntrenamientos(at offsets: IndexSet) {
        for index in offsets {
            let entrenamientoAEliminar = entrenamientosRealizadosEntrenamiento[index]
            modelContext.delete(entrenamientoAEliminar)
        }
    }
}
