//
//  EntrenamientoListView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftData
import SwiftUI

struct EntrenamientoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entrenamiento.fecha, order: .reverse) var entrenamientos: [Entrenamiento]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var selectedEntrenamiento: Entrenamiento?
    @State private var showCrearEntrenamientoSheet = false

    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone
            NavigationView {
                List {
                    ForEach(entrenamientos) { entrenamiento in
                        NavigationLink(destination: DetalleEntrenamientoView(entrenamiento: entrenamiento)) {
                            VStack(alignment: .leading) {
                                Text(entrenamiento.nombre)
                                    .font(.headline)
                                Text("Fecha: \(entrenamiento.fecha, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: eliminarEntrenamiento)
                }
                .navigationTitle("Entrenamientos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CrearEntrenamientoView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        } else {
            // iPad
            NavigationSplitView {
                List(selection: $selectedEntrenamiento) {
                    ForEach(entrenamientos) { entrenamiento in
                        VStack(alignment: .leading) {
                            Text(entrenamiento.nombre)
                                .font(.headline)
                            Text("Fecha: \(entrenamiento.fecha, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .tag(entrenamiento)
                    }
                    .onDelete(perform: eliminarEntrenamiento)
                }
                .navigationTitle("Entrenamientos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCrearEntrenamientoSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .sheet(isPresented: $showCrearEntrenamientoSheet) {
                            CrearEntrenamientoView()
                        }
                    }
                }
            } detail: {
                if let entrenamiento = selectedEntrenamiento {
                    DetalleEntrenamientoView(entrenamiento: entrenamiento)
                } else {
                    Text("Selecciona un entrenamiento")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func eliminarEntrenamiento(at offsets: IndexSet) {
        for index in offsets {
            let entrenamiento = entrenamientos[index]
            modelContext.delete(entrenamiento)
        }
    }
}


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

