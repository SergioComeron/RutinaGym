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
    
    var body: some View {
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

