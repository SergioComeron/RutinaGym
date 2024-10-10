//
//  CrearEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI
import SwiftData

struct CrearEntrenamientoView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var nombre: String = ""
    @State private var fecha: Date = Date()
    @State private var series: [Serie] = []
    @State private var mostrarCrearSerie = false
    @Environment(\.dismiss) private var dismiss // Agregamos dismiss para poder cerrar la vista

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
                                        Text("Ejercicio: \(ejercicio.nombre)")
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
            .navigationTitle("Crear Entrenamiento")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarEntrenamiento()
                    }
                    .disabled(nombre.isEmpty || series.isEmpty)
                }
            }
        }
    }
    
    private func eliminarSerie(at offsets: IndexSet) {
        series.remove(atOffsets: offsets)
    }
    
    private func guardarEntrenamiento() {
        let nuevoEntrenamiento = Entrenamiento(nombre: nombre, fecha: fecha)
        modelContext.insert(nuevoEntrenamiento)
        
        // Asignar el entrenamiento a cada serie y guardarlas
        for serie in series {
            serie.entrenamiento = nuevoEntrenamiento
            modelContext.insert(serie)
        }
        
        // Guardar el contexto
        try? modelContext.save()
        
        // Cerrar la vista para regresar a la vista principal
        dismiss()
    }
}

