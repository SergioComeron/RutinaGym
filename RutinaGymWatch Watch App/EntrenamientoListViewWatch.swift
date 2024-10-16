//
//  EntrenamientoListViewWatch.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftData
import SwiftUI

struct EntrenamientoListViewWatch: View {
    @Query(sort: \Entrenamiento.fecha, order: .reverse) var entrenamientos: [Entrenamiento]

    var body: some View {
        NavigationView {
            List {
                ForEach(entrenamientos) { entrenamiento in
                    NavigationLink(destination: DetalleEntrenamientoViewWatch(entrenamiento: entrenamiento)) {
                        VStack(alignment: .leading) {
                            Text(entrenamiento.nombre)
                                .font(.headline)
                            Text("Fecha: \(entrenamiento.fecha, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Entrenamientos")
            
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

