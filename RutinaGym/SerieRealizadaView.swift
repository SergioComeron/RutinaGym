//
//  SerieRealizadaView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 14/10/24.
//
import SwiftUI
import SwiftData
import Charts

struct SerieRealizadaView: View {
    var seriesPlanificadas: [Serie]
    @Bindable var entrenamientoRealizado: EntrenamientoRealizado
    @State private var currentIndex = 0
    @State private var pesoUtilizado: String = ""
    @State private var repeticionesRealizadas: String = ""
    @Environment(\.modelContext) private var modelContext
    @State private var seriesGuardadas: [Int: Bool] = [:] // Diccionario para mantener el estado de series guardadas
    @Query private var todasLasSeriesRealizadas: [SerieRealizada] // Utiliza Query para obtener las series

    var body: some View {
        VStack {
            if !seriesPlanificadas.isEmpty {
                // Ordenar las series planificadas antes de mostrarlas
                let seriesOrdenadas = seriesPlanificadas.sorted(by: { $0.fechaCreacion < $1.fechaCreacion })
                
                TabView(selection: $currentIndex) {
                    ForEach(0..<seriesOrdenadas.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            let seriePlanificada = seriesOrdenadas[index]
                            Text(seriePlanificada.ejercicios?.nombre ?? "Ejercicio sin nombre")
                                .font(.headline)
                            Text("Tipo de Serie: \(seriePlanificada.tipoSerie.rawValue.capitalized)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Repeticiones planificadas: \(seriePlanificada.repeticiones ?? 0)")
                            TextField("Peso utilizado", text: $pesoUtilizado)
                                .keyboardType(.decimalPad)
                            TextField("Repeticiones realizadas", text: $repeticionesRealizadas)
                                .keyboardType(.numberPad)
                            Button("Guardar Serie") {
                                guardarSerie(seriePlanificada: seriePlanificada, index: index)
                            }
                            .disabled(seriesGuardadas[index] == true) // Deshabilitar si ya está guardado
                            .padding(.top, 5)
                            // Gráfico de los pesos registrados en todas las series del mismo ejercicio
                            if let ejercicio = seriePlanificada.ejercicios {
                                Chart {
                                    // Filtrar todas las series realizadas para mostrar las del mismo ejercicio
                                    let seriesFiltradas = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios == ejercicio }
                                    ForEach(seriesFiltradas) { serieRealizada in
                                        if let peso = serieRealizada.pesoUtilizado {
                                            LineMark(
                                                x: .value("Fecha", serieRealizada.fecha),
                                                y: .value("Peso", peso)
                                            )
                                            .symbol(Circle())
                                        }
                                    }
                                }
                                .frame(height: 200)
                                .padding(.top, 10)
                            }
                        }
                        .padding()
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 450) // Ajustar la altura según sea necesario
            } else {
                Text("No hay más series planificadas")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
        }
        .padding()
    }
    
    private func guardarSerie(seriePlanificada: Serie, index: Int) {
        // Crear la nueva serie realizada
        let nuevaSerieRealizada = SerieRealizada(
            seriePlanificada: seriePlanificada,
            pesoUtilizado: Double(pesoUtilizado),
            repeticionesRealizadas: Int(repeticionesRealizadas),
            observaciones: "",
            entrenamientoRealizado: entrenamientoRealizado
        )
        
        // Añadir la nueva serie al entrenamiento
        if var seriesRealizadas = entrenamientoRealizado.seriesRealizadas {
            seriesRealizadas.append(nuevaSerieRealizada)
        }
        
        modelContext.insert(nuevaSerieRealizada)
        
        // Marcar la serie como guardada
        seriesGuardadas[index] = true

        // Opcional: Guarda el contexto si es necesario
        // try? modelContext.save()
    }
}


