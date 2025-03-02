//
//  ResumenEntrenamientoView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 15/10/24.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct ResumenEntrenamientoView: View {
    var entrenamientoRealizado: EntrenamientoRealizado
    // Nuevo estado para presentar el menú de compartir
    @State private var mostrarCompartir = false
    @State private var contenidoCompartir: [Any] = []
    
    @Query private var todasLasSeriesRealizadas: [SerieRealizada] // Utiliza Query para obtener las series

    // Agrupamos las series realizadas por ejercicio y obtenemos los pesos usados
    var seriesPorEjercicio: [String: [SerieRealizada]] {
        Dictionary(grouping: entrenamientoRealizado.seriesRealizadas ?? [], by: { $0.seriePlanificada?.ejercicios?.nombre ?? "Desconocido" })
    }
    
    // Función que calcula el peso máximo realizado a lo largo del tiempo para un ejercicio específico
    func obtenerPesoMaximoGlobal(ejercicio: String) -> Double {
        let seriesDeEjercicio = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == ejercicio }
        let pesoMaximo = seriesDeEjercicio.compactMap { $0.pesoUtilizado }.max() ?? 0.0
        return pesoMaximo
    }
    
    // Función para formatear el intervalo de tiempo
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var body: some View {
        VStack {
            if let fechaInicio = entrenamientoRealizado.fechaInicio, let fechaFin = entrenamientoRealizado.fechaFin {
                Text("Inicio: \(fechaInicio, formatter: dateTimeFormatter) - Fin: \(fechaFin, formatter: dateTimeFormatter)")
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            
            
            List {
                ForEach(seriesPorEjercicio.keys.sorted(), id: \.self) { ejercicio in
                    VStack(alignment: .leading) {
                        // Estilizar el nombre del ejercicio para que resalte más
                        Text(ejercicio)
                            .font(.title2) // Aumenta el tamaño de la fuente
                            .fontWeight(.bold) // Aplica negrita
                            .foregroundColor(.blue) // Cambia el color del texto
                            .padding(.vertical, 5)
                        
                        Divider() // Agrega una línea divisoria para separar visualmente
                        
                        // Obtenemos el peso máximo a lo largo del tiempo para este ejercicio
                        let pesoMaximoGlobal = obtenerPesoMaximoGlobal(ejercicio: ejercicio)
                        
                        // Obtenemos las series realizadas para este ejercicio y las ordenamos por fecha
                        if let series = seriesPorEjercicio[ejercicio] {
                            let seriesOrdenadas = series.sorted { $0.fecha < $1.fecha }
                            
                            ForEach(seriesOrdenadas.indices, id: \.self) { index in
                                let serie = seriesOrdenadas[index]
                                // Mostrar el tiempo entre esta serie y la anterior
                                if index > 0 {
                                    let serieAnterior = seriesOrdenadas[index - 1]
                                    let timestampActual = serie.fecha
                                    let timestampAnterior = serieAnterior.fecha
                                    let diferenciaTiempo = timestampActual.timeIntervalSince(timestampAnterior)
                                    Text("Tiempo entre series: \(formatTimeInterval(diferenciaTiempo))")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                        .padding(.leading, 20)
                                }
                                HStack {
                                    if let peso = serie.pesoUtilizado {
                                        // Si el peso de la serie es el máximo a lo largo del tiempo, agregamos el símbolo
                                        Text("Peso: \(String(format: "%.2f", peso)) kg")
                                            .font(.body)
                                            .foregroundColor(peso == pesoMaximoGlobal ? .red : .primary)
                                        
                                        if peso == pesoMaximoGlobal {
                                            Text("⭐️") // Símbolo para marcar la serie con el peso máximo global
                                        }
                                    }
                                    
                                    if let repeticiones = serie.repeticionesRealizadas {
                                        Text("Repeticiones: \(repeticiones)")
                                            .font(.body)
                                            .padding(.leading, 10)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            // Añadimos el botón de compartir
            Button(action: {
                // Generamos el contenido a compartir
                let textoCompartir = generarTextoCompartir()
                contenidoCompartir = [textoCompartir]
                mostrarCompartir = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom, 10)
            .sheet(isPresented: $mostrarCompartir) {
                // Presentamos el menú de compartir
                ActivityView(activityItems: contenidoCompartir)
            }
        }
        .navigationTitle("Resumen de Entrenamiento")
        .padding()
    }
    
    func generarTextoCompartir() -> String {
        var texto = ""
        if let fechaInicio = entrenamientoRealizado.fechaInicio, let fechaFin = entrenamientoRealizado.fechaFin {
            let fechaInicioFormateada = dateTimeFormatter.string(from: fechaInicio)
            let fechaFinFormateada = dateTimeFormatter.string(from: fechaFin)
            texto += "Inicio: \(fechaInicioFormateada) - Fin: \(fechaFinFormateada)\n\n"
        }

        for ejercicio in seriesPorEjercicio.keys.sorted() {
            texto += "\(ejercicio.uppercased())\n"
            if let series = seriesPorEjercicio[ejercicio] {
                let seriesOrdenadas = series.sorted { $0.fecha < $1.fecha }
                for index in seriesOrdenadas.indices {
                    let serie = seriesOrdenadas[index]
                    if index > 0 {
                        let serieAnterior = seriesOrdenadas[index - 1]
                        let timestampActual = serie.fecha
                        let timestampAnterior = serieAnterior.fecha
                        let diferenciaTiempo = timestampActual.timeIntervalSince(timestampAnterior)
                        texto += "Tiempo entre series: \(formatTimeInterval(diferenciaTiempo))\n"
                    } else if let fechaInicio = entrenamientoRealizado.fechaInicio {
                        let timestampActual = serie.fecha
                        let diferenciaTiempo = timestampActual.timeIntervalSince(fechaInicio)
                        texto += "Tiempo desde inicio: \(formatTimeInterval(diferenciaTiempo))\n"
                    }
                    if let peso = serie.pesoUtilizado, let repeticiones = serie.repeticionesRealizadas {
                        texto += "Peso: \(String(format: "%.2f", peso)) kg, Repeticiones: \(repeticiones)\n"
                    }
                }
                texto += "\n"
            }
        }
        return texto
    }

    // Formato de fecha con hora
    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// Vista auxiliar para presentar el UIActivityViewController en SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
