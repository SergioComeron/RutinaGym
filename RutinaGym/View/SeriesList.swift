//
//  SeriesList.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI
import SwiftData


struct SerieListView: View {
    // Utilizamos @Query para obtener todas las instancias de Serie desde SwiftData
    @Query var series: [Serie]
    
    var body: some View {
        NavigationView {
            List(series) { serie in
                VStack(alignment: .leading) {
                    Text("Repeticiones: \(serie.repeticiones ?? 0)")
                        .font(.headline)
                    Text("Tipo de Serie: \(serie.tipoSerie.rawValue.capitalized)")
                        .font(.subheadline)
                    if let descripcion = serie.descripcion {
                        Text("Descripción: \(descripcion)")
                            .font(.body)
                    }
                }
                .padding(5)
            }
            .navigationTitle("Listado de Series")
        }
    }
}

//#Preview {
//    SerieListView(series: [Serie(repeticiones: 3, ejercicios: vm.ejercicios.first, tipoSerie: .normal)])
//}
