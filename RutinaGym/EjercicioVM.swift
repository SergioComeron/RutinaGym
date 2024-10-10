//
//  EjercicioVM.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftUI

@Observable
final class EjercicioVM {
    let repository: DataRepository
    
    var ejercicios: [Ejercicio]
    
    init(repository: DataRepository = Repository()) {
        self.repository = repository
        do {
            ejercicios = try repository.getData()
        } catch {
            print(error)
            ejercicios = []
        }
    }
}
