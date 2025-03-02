//
//  EjercicioView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftUI

struct EjercicioView: View {
    let ejercicio: Ejercicio
    
    var body: some View {
        VStack {
            Text(ejercicio.nombre)
                .font(.headline)
                .padding()
            
            Text(ejercicio.descripcion)
                .font(.subheadline)
                .padding()
        }
        
    }
}
