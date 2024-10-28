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
    @StateObject private var viewModel: SerieRealizadaViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var todasLasSeriesRealizadas: [SerieRealizada]
    @AppStorage("liveactivity") var activityIdentifier: String = ""
    var seriesPlanificadas: [Serie]
        var entrenamientoRealizado: EntrenamientoRealizado
    init(seriesPlanificadas: [Serie], entrenamientoRealizado: EntrenamientoRealizado) {
        self.seriesPlanificadas = seriesPlanificadas
        self.entrenamientoRealizado = entrenamientoRealizado
        _viewModel = StateObject(wrappedValue: SerieRealizadaViewModel(
            seriesPlanificadas: seriesPlanificadas,
            entrenamientoRealizado: entrenamientoRealizado,
            todasLasSeriesRealizadas: [] // Inicialmente vacío
        ))
    }
    
    var body: some View {
        VStack {
            // Mostrar el resumen del entrenamiento
            if let resumen = entrenamientoRealizado.entrenamientoPlanificado?.seriesResumen {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Resumen del Entrenamiento")
                        .font(.headline)
                    ForEach(resumen, id: \.self) { item in
                        Text(item)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
            if viewModel.entrenamientoCompletado {
                Text("¡Entrenamiento completado!")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .padding()
            } else if !viewModel.seriesPlanificadas.isEmpty {
                let seriesOrdenadas = viewModel.seriesPlanificadas.sorted(by: { $0.fechaCreacion < $1.fechaCreacion })
                
                TabView(selection: $viewModel.currentIndex) {
                    ForEach(0..<seriesOrdenadas.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 20) {
                            let seriePlanificada = seriesOrdenadas[index]
                            VStack(alignment: .leading, spacing: 15) {
                                Text("\(seriePlanificada.ejercicios?.nombre ?? "")")
                                    .font(.title3)
                                Text("Tipo de Serie: \(seriePlanificada.tipoSerie.rawValue.capitalized)")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text("Repeticiones planificadas: \(seriePlanificada.repeticiones ?? 0)")
                                    .font(.title3)
                                
                                // Obtener el peso máximo registrado para el ejercicio actual
                                let pesoMaximo = viewModel.pesoMaximoParaEjercicio(seriePlanificada.ejercicios?.nombre)
                                
                                if let pesoMaximo = pesoMaximo {
                                    Text("Peso máximo registrado: \(pesoMaximo, specifier: "%.2f") kg")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }
                                
                                // Botones y campos de texto más grandes
                                HStack(spacing: 15) {
                                    Button("-") {
                                        viewModel.ajustarPeso(-0.5)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)
                                    
                                    TextField("Peso utilizado", text: $viewModel.pesoUtilizado)
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, 10)
                                        .font(.title3) // Tamaño más grande para el campo de texto
                                        .textFieldStyle(.roundedBorder)
                                        .onAppear {
                                            viewModel.pesoUtilizado = "\(pesoMaximo ?? 0)"
                                        }
                                    
                                    Button("+") {
                                        viewModel.ajustarPeso(0.5)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)
                                }
                                
                                HStack(spacing: 15) {
                                    Button("-") {
                                        viewModel.ajustarRepeticiones(-1)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)
                                    
                                    TextField("Repeticiones realizadas", text: $viewModel.repeticionesRealizadas)
                                        .keyboardType(.numberPad)
                                        .padding(.vertical, 10)
                                        .font(.title3) // Tamaño más grande para el campo de texto
                                        .textFieldStyle(.roundedBorder)
                                        .onAppear {
                                            viewModel.repeticionesRealizadas = "\(seriePlanificada.repeticiones ?? 0)"
                                        }
                                    
                                    Button("+") {
                                        viewModel.ajustarRepeticiones(1)
                                    }
                                    .buttonStyle(.bordered)
                                    .font(.title2)
                                }
                                
                                Button("Guardar Serie") {
                                    let seriePlanificada = seriesOrdenadas[viewModel.currentIndex]
                                    viewModel.guardarSerie(seriePlanificada: seriePlanificada, index: viewModel.currentIndex, modelContext: modelContext)
                                }
                                .disabled(viewModel.seriesGuardadas[viewModel.currentIndex] == true)
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
                            .onAppear {
                                Task {
                                    let pesoMaximo = viewModel.pesoMaximoParaEjercicio(seriePlanificada.ejercicios?.nombre)
                                    if let pesoMaximo = pesoMaximo {
                                        await TrainingActivityUseCase.updateActivity(activityIdentifier: activityIdentifier, serie: seriePlanificada, pesoMaximo: pesoMaximo)
                                    }
                                }
                            }
                        }
                        .padding()
                        .tag(index)
                        .transition(.slide)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always)) // Los puntos de la paginación abajo
                .frame(height: 600) // Incrementar el tamaño de la vista
                .animation(.easeInOut, value: viewModel.currentIndex)
            } else {
                Text("No hay más series planificadas")
                    .foregroundColor(.gray)
                    .font(.largeTitle) // Texto más grande para los mensajes de aviso
            }
        }
        .padding()
        .onAppear {
            viewModel.todasLasSeriesRealizadas = todasLasSeriesRealizadas
        }
        .onChange(of: todasLasSeriesRealizadas) {
            viewModel.todasLasSeriesRealizadas = todasLasSeriesRealizadas
        }
    }
}



