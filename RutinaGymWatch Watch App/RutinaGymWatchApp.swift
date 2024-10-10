//
//  RutinaGymWatchApp.swift
//  RutinaGymWatch Watch App
//
//  Created by Sergio Comerón Sánchez-Pani on 10/10/24.
//

import SwiftUI

@main
struct RutinaGymWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Serie.self, Entrenamiento.self])
        }
    }
}
