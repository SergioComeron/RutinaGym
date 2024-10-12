//
//  DetalleEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI

struct DetalleEntrenamientoView: View {
    var entrenamiento: Entrenamiento
    @State private var mostrarEditarEntrenamiento = false // Estado para mostrar la vista de edición
    @State private var mostrarSeriesDetalladas = false    // Estado para mostrar/ocultar Series Detalladas

    var body: some View {
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

            // Botón para mostrar/ocultar Series Detalladas
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
            .buttonStyle(PlainButtonStyle()) // Para que el botón se vea como una celda de la lista

            // Sección Series Detalladas condicionada al estado mostrarSeriesDetalladas
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
    }
}


