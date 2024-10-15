//
//  RutinaGymApp.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftUI

@main
struct RutinaGymApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Serie.self, Entrenamiento.self, SerieRealizada.self, EntrenamientoRealizado.self])
        }
    }
}
