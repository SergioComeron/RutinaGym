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
    @State private var entrenamientoCompletado = false // Estado para comprobar si el entrenamiento está completo
    @Environment(\.colorScheme) var colorScheme // Para detectar el modo oscuro o claro

    var body: some View {
        VStack {
            
            if entrenamientoCompletado {
                Text("¡Entrenamiento completado!")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .padding()
            } else if !seriesPlanificadas.isEmpty {
                let seriesOrdenadas = seriesPlanificadas.sorted(by: { $0.fechaCreacion < $1.fechaCreacion })

                TabView(selection: $currentIndex) {
                    ForEach(0..<seriesOrdenadas.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 20) {
                            let seriePlanificada = seriesOrdenadas[index]

                            VStack(alignment: .leading, spacing: 15) {
                                // El título del ejercicio ha sido eliminado

                                Text("Tipo de Serie: \(seriePlanificada.tipoSerie.rawValue.capitalized)")
                                    .font(.title3)
                                    .foregroundColor(.secondary)

                                Text("Repeticiones planificadas: \(seriePlanificada.repeticiones ?? 0)")
                                    .font(.title3)

                                // Obtener el peso máximo registrado para el ejercicio actual
                                let pesoMaximo = pesoMaximoParaEjercicio(seriePlanificada.ejercicios?.nombre)

                                if let pesoMaximo = pesoMaximo {
                                    Text("Peso máximo registrado: \(pesoMaximo, specifier: "%.2f") kg")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }

                                // Botones y campos de texto más grandes
                                HStack(spacing: 15) {
                                    Button("-") {
                                        ajustarPeso(-0.5)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)

                                    TextField("Peso utilizado", text: $pesoUtilizado)
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, 10)
                                        .font(.title3) // Tamaño más grande para el campo de texto
                                        .textFieldStyle(.roundedBorder)
                                        .onAppear {
                                            pesoUtilizado = "\(pesoMaximo ?? 0)"
                                        }

                                    Button("+") {
                                        ajustarPeso(0.5)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)
                                }

                                HStack(spacing: 15) {
                                    Button("-") {
                                        ajustarRepeticiones(-1)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)

                                    TextField("Repeticiones realizadas", text: $repeticionesRealizadas)
                                        .keyboardType(.numberPad)
                                        .padding(.vertical, 10)
                                        .font(.title3) // Tamaño más grande para el campo de texto
                                        .textFieldStyle(.roundedBorder)
                                        .onAppear {
                                            repeticionesRealizadas = "\(seriePlanificada.repeticiones ?? 0)"
                                        }

                                    Button("+") {
                                        ajustarRepeticiones(1)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)
                                }

                                Button("Guardar Serie") {
                                    guardarSerie(seriePlanificada: seriePlanificada, index: index)
                                }
                                .disabled(seriesGuardadas[index] == true)
                                .padding(.top, 20)
                                .font(.title3)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(colorScheme == .dark ? Color.black : Color.white)
                                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                        }
                        .padding()
                        .tag(index)
                        .transition(.slide)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always)) // Los puntos de la paginación abajo
                .frame(height: 600) // Incrementar el tamaño de la vista
                .animation(.easeInOut, value: currentIndex)
            } else {
                Text("No hay más series planificadas")
                    .foregroundColor(.gray)
                    .font(.largeTitle) // Texto más grande para los mensajes de aviso
            }
            ProgressView(value: Double(currentIndex + 1), total: Double(seriesPlanificadas.count))
                .scaleEffect(1.5) // Aumentar tamaño del ProgressView
                .padding(.vertical, 20)

        }
        .padding()
        .onAppear {
            inicializarSeriesGuardadas()
        }
        
    }

    // Ajuste de peso y repeticiones (sin cambios)
    private func ajustarPeso(_ cantidad: Double) {
        if let pesoActual = Double(pesoUtilizado) {
            let nuevoPeso = max(0, pesoActual + cantidad)
            pesoUtilizado = String(format: "%.2f", nuevoPeso)
        }
    }

    private func ajustarRepeticiones(_ cantidad: Int) {
        if let repeticionesActuales = Int(repeticionesRealizadas) {
            let nuevasRepeticiones = max(0, repeticionesActuales + cantidad)
            repeticionesRealizadas = "\(nuevasRepeticiones)"
        }
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
        if entrenamientoRealizado.seriesRealizadas == nil {
            entrenamientoRealizado.seriesRealizadas = []
        }

        entrenamientoRealizado.seriesRealizadas?.append(nuevaSerieRealizada)
        modelContext.insert(nuevaSerieRealizada)

        // Marcar la serie como guardada
        seriesGuardadas[index] = true

        // Comprobar si todas las series planificadas han sido guardadas
        let totalSeriesPlanificadas = seriesPlanificadas.count
        let totalSeriesGuardadas = seriesGuardadas.filter { $0.value == true }.count

        if totalSeriesGuardadas == totalSeriesPlanificadas {
            entrenamientoCompletado = true
        } else {
            if currentIndex < seriesPlanificadas.count - 1 {
                withAnimation {
                    currentIndex += 1
                }
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Error guardando el contexto: \(error)")
        }
    }

    private func pesoMaximoParaEjercicio(_ nombreEjercicio: String?) -> Double? {
        guard let nombreEjercicio = nombreEjercicio else { return nil }
        let seriesFiltradas = todasLasSeriesRealizadas.filter { $0.seriePlanificada?.ejercicios?.nombre == nombreEjercicio }
        return seriesFiltradas.map { $0.pesoUtilizado ?? 0 }.max()
    }

    private func inicializarSeriesGuardadas() {
        for index in 0..<seriesPlanificadas.count {
            seriesGuardadas[index] = false
        }
    }
}



