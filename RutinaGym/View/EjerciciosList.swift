//
//  EjerciciosList.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftUI
import Foundation

struct EjerciciosList: View {
    @State var vm = EjercicioVM(repository: RepositoryWeb())
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredEjercicios) { ejercicio in
                    NavigationLink(destination: EjercicioView(ejercicio: ejercicio)) {
                        Text(ejercicio.nombre)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar ejercicios")
            .navigationTitle("Ejercicios")
        }
    }
    
    var filteredEjercicios: [Ejercicio] {
        if searchText.isEmpty {
            return vm.ejercicios
        } else {
            return vm.ejercicios.filter { $0.nombre.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    EjerciciosList(vm: EjercicioVM(repository: RepositoryWeb()))
}
