//
//  EditarEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI
import SwiftData

struct EditarEntrenamientoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var nombre: String
    @State var fecha: Date
    @State var series: [Serie] // Series existentes del entrenamiento
    @State private var mostrarCrearSerie = false

    var entrenamiento: Entrenamiento

    init(entrenamiento: Entrenamiento) {
        self.entrenamiento = entrenamiento
        _nombre = State(initialValue: entrenamiento.nombre)
        _fecha = State(initialValue: entrenamiento.fecha)
        _series = State(initialValue: entrenamiento.series ?? [])
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Entrenamiento")) {
                    TextField("Nombre del Entrenamiento", text: $nombre)
                    DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                }

                Section(header: Text("Series")) {
                    if series.isEmpty {
                        Text("No hay series agregadas")
                            .foregroundColor(.gray)
                    } else {
                        List {
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
                                    Text("Repeticiones: \(serie.repeticiones)")
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
                            .onDelete(perform: eliminarSerie)
                        }
                    }
                    Button(action: {
                        mostrarCrearSerie = true
                    }) {
                        Text("Agregar Serie")
                    }
                    .sheet(isPresented: $mostrarCrearSerie) {
                        CrearSerieView { nuevaSerie in
                            series.append(nuevaSerie)
                        }
                    }
                }
            }
            .navigationTitle("Editar Entrenamiento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarCambios()
                        dismiss()
                    }
                }
            }
        }
    }

    private func eliminarSerie(at offsets: IndexSet) {
        series.remove(atOffsets: offsets)
    }

    private func guardarCambios() {
        entrenamiento.nombre = nombre
        entrenamiento.fecha = fecha
        entrenamiento.series = series
        try? modelContext.save() // Guarda los cambios en el contexto
    }
}
