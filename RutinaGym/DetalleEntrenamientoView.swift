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
    
    @Query private var todasLasSeriesRealizadas: [SerieRealizada] // Consulta todas las series realizadas

    private var entrenamientosRealizadosEntrenamiento: [EntrenamientoRealizado] {
        entrenamientosRealizados.filter { $0.entrenamientoPlanificado == entrenamiento }
    }

    // Función que calcula el peso máximo global para un ejercicio específico
    private func obtenerPesoMaximoGlobal(ejercicio: String) -> Double {
        let seriesDeEjercicio = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == ejercicio }
        return seriesDeEjercicio.compactMap { $0.pesoUtilizado }.max() ?? 0.0
    }

    // Función que determina si algún ejercicio de las series de un entrenamiento alcanzó el peso máximo
    private func tienePesoMaximo(entrenamientoRealizado: EntrenamientoRealizado) -> Bool {
        for serieRealizada in entrenamientoRealizado.seriesRealizadas ?? [] {
            if let ejercicio = serieRealizada.seriePlanificada?.ejercicios?.nombre,
               let peso = serieRealizada.pesoUtilizado {
                let pesoMaximo = obtenerPesoMaximoGlobal(ejercicio: ejercicio)
                if peso == pesoMaximo {
                    return true // Si alguna serie tiene el peso máximo, devuelve verdadero
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
                    Section(header: Text("Detalles")) {
                        Text("Nombre: \(entrenamiento.nombre)")
                        Text("Fecha: \(entrenamiento.fecha, formatter: dateFormatter)")
                    }

                    Section(header: Text("Resumen de Series")) {
                        if entrenamiento.seriesResumen.isEmpty {
                            Text("No hay series para este entrenamiento")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(entrenamiento.seriesResumen, id: \.self) { resumen in
                                Text(resumen)
                            }
                        }
                    }

//                    Button(action: {
//                        withAnimation {
//                            mostrarSeriesDetalladas.toggle()
//                        }
//                    }) {
//                        HStack {
//                            Text(mostrarSeriesDetalladas ? "Ocultar Series Detalladas" : "Mostrar Series Detalladas")
//                            Spacer()
//                            Image(systemName: mostrarSeriesDetalladas ? "chevron.up" : "chevron.down")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .buttonStyle(PlainButtonStyle())
//
//                    if mostrarSeriesDetalladas {
//                        Section(header: Text("Series Detalladas")) {
//                            if let series = entrenamiento.series, !series.isEmpty {
//                                ForEach(series) { serie in
//                                    VStack(alignment: .leading) {
//                                        if let ejercicio = serie.ejercicios {
//                                            Text(ejercicio.nombre)
//                                                .font(.headline)
//                                        } else {
//                                            Text("Ejercicio no disponible")
//                                                .font(.headline)
//                                                .foregroundColor(.red)
//                                        }
//                                        if let repeticiones = serie.repeticiones {
//                                            Text("Repeticiones: \(repeticiones)")
//                                        } else {
//                                            Text("Repeticiones: No establecidas")
//                                        }
//                                        Text("Tipo de Serie: \(serie.tipoSerie.rawValue.capitalized)")
//                                        if let descripcion = serie.descripcion {
//                                            Text("Descripción: \(descripcion)")
//                                        }
//                                        if let observaciones = serie.observaciones {
//                                            Text("Observaciones: \(observaciones)")
//                                        }
//                                    }
//                                    .padding(.vertical, 5)
//                                }
//                            } else {
//                                Text("No hay series para este entrenamiento")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    }

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
                                            // Si algún ejercicio alcanzó el peso máximo, mostrar la estrella
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
        
        if let serie = entrenamiento.series?.first {
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













