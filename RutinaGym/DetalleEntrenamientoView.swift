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

    @State private var mostrarEditarEntrenamiento = false
    @State private var mostrarSeriesDetalladas = false
    @State private var entrenamientoEnCurso: EntrenamientoRealizado?
    @State private var mostrandoAlertaFinalizar = false
    @State private var entrenamientoSeleccionado: EntrenamientoRealizado?

    @Query(sort: \EntrenamientoRealizado.fechaInicio, order: .reverse)
    var entrenamientosRealizados: [EntrenamientoRealizado]

    private var entrenamientosRealizadosEntrenamiento: [EntrenamientoRealizado] {
        entrenamientosRealizados.filter { $0.entrenamientoPlanificado == entrenamiento }
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

                    Button(action: {
                        withAnimation {
                            mostrarSeriesDetalladas.toggle()
                        }
                    }) {
                        HStack {
                            Text(mostrarSeriesDetalladas ? "Ocultar Series Detalladas" : "Mostrar Series Detalladas")
                            Spacer()
                            Image(systemName: mostrarSeriesDetalladas ? "chevron.up" : "chevron.down")
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    if mostrarSeriesDetalladas {
                        Section(header: Text("Series Detalladas")) {
                            if let series = entrenamiento.series, !series.isEmpty {
                                ForEach(series) { serie in
                                    VStack(alignment: .leading) {
                                        if let ejercicio = serie.ejercicios {
                                            Text(ejercicio.nombre)
                                                .font(.headline)
                                        } else {
                                            Text("Ejercicio no disponible")
                                                .font(.headline)
                                                .foregroundColor(.red)
                                        }
                                        if let repeticiones = serie.repeticiones {
                                            Text("Repeticiones: \(repeticiones)")
                                        } else {
                                            Text("Repeticiones: No establecidas")
                                        }
                                        Text("Tipo de Serie: \(serie.tipoSerie.rawValue.capitalized)")
                                        if let descripcion = serie.descripcion {
                                            Text("Descripción: \(descripcion)")
                                        }
                                        if let observaciones = serie.observaciones {
                                            Text("Observaciones: \(observaciones)")
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            } else {
                                Text("No hay series para este entrenamiento")
                                    .foregroundColor(.gray)
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
                                        if let fechaInicio = entrenamientoRealizado.fechaInicio {
                                            Text("Fecha: \(fechaInicio, formatter: dateFormatter)")
                                                .font(.headline)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(entrenamiento.nombre)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Editar") {
                            mostrarEditarEntrenamiento = true
                        }
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
    }
}










