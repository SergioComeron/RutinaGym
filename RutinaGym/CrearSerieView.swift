//
//  CrearSerieView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftUI

struct CrearSerieView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var repeticiones: Int = 15
    @State private var descripcion: String = ""
    @State private var tipoSerie: TipoSerie = .normal
    @State private var ejercicio: Ejercicio?
    @State private var observaciones: String = ""
    @Environment(\.modelContext) private var modelContext
    @State var vm = EjercicioVM()
    @State private var mostrarSelectorDeEjercicio = false
    @State private var numeroDeSeries: Int = 4
    @State private var repeticionesPorSerie: [Int] = []

    // Closure para devolver la serie creada
    var onSave: (Serie) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tipo de Serie")) {
                    Picker("Tipo de Serie", selection: $tipoSerie) {
                        ForEach(TipoSerie.allCases, id: \.self) { tipo in
                            Text(tipo.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: tipoSerie) {
                        adjustRepeticionesPorSerie()
                    }
                }

                Section(header: Text("Número de Series")) {
                    Stepper(value: $numeroDeSeries, in: 1...10) {
                        Text("Número de Series: \(numeroDeSeries)")
                    }
                    .onChange(of: numeroDeSeries) {
                        adjustRepeticionesPorSerie()
                    }
                }

                Section(header: Text("Detalles de la Serie")) {
                    if tipoSerie == .subiendoPeso {
                        ForEach(0..<numeroDeSeries, id: \.self) { index in
                            Stepper(value: Binding(
                                get: {
                                    repeticionesPorSerie.indices.contains(index) ? repeticionesPorSerie[index] : 10
                                },
                                set: { newValue in
                                    if repeticionesPorSerie.indices.contains(index) {
                                        repeticionesPorSerie[index] = newValue
                                    } else {
                                        repeticionesPorSerie.append(newValue)
                                    }
                                }
                            ), in: 1...20) {
                                Text("Serie \(index + 1): \(repeticionesPorSerie.indices.contains(index) ? repeticionesPorSerie[index] : 10) repeticiones")
                            }
                        }
                    } else {
                        Stepper(value: $repeticiones, in: 1...20) {
                            Text("Repeticiones: \(repeticiones)")
                        }
                    }

                    TextField("Descripción", text: $descripcion)
                }

                Section(header: Text("Ejercicio")) {
                    Button(action: {
                        mostrarSelectorDeEjercicio = true
                    }) {
                        if let ejercicio = ejercicio {
                            Text(ejercicio.nombre)
                        } else {
                            Text("Seleccionar Ejercicio")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $mostrarSelectorDeEjercicio) {
                        SelectorDeEjercicioView(
                            ejercicios: vm.ejercicios,
                            ejercicioSeleccionado: $ejercicio,
                            mostrarSelectorDeEjercicio: $mostrarSelectorDeEjercicio
                        )
                    }
                }

                Section(header: Text("Observaciones")) {
                    ZStack {
                        TextEditor(text: $observaciones)
                            .frame(height: 150)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        if observaciones.isEmpty {
                            Text("Escribe tus observaciones aquí...")
                                .foregroundColor(.gray)
                                .padding(8)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .navigationTitle("Crear Serie")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarSerie()
                    }
                    .disabled(ejercicio == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                adjustRepeticionesPorSerie()
            }
        }
    }

    struct SelectorDeEjercicioView: View {
        let ejercicios: [Ejercicio]
        @Binding var ejercicioSeleccionado: Ejercicio?
        @Binding var mostrarSelectorDeEjercicio: Bool

        @State private var grupoSeleccionado: GrupoMuscular = .hombros
        private var ejerciciosFiltrados: [Ejercicio] {
            ejercicios.filter { $0.grupoMuscular == grupoSeleccionado }
        }

        var body: some View {
            NavigationView {
                VStack {
                    Picker("Grupo Muscular", selection: $grupoSeleccionado) {
                        ForEach(GrupoMuscular.allCases, id: \.self) { grupo in
                            Text(grupo.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()

                    List(ejerciciosFiltrados) { ejercicio in
                        Button(action: {
                            ejercicioSeleccionado = ejercicio
                            mostrarSelectorDeEjercicio.toggle()
                        }) {
                            Text(ejercicio.nombre)
                        }
                    }
                }
                .navigationTitle("Seleccionar Ejercicio")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            mostrarSelectorDeEjercicio.toggle()
                        }
                    }
                }
            }
        }
    }

    private func adjustRepeticionesPorSerie() {
        if tipoSerie == .subiendoPeso {
            if repeticionesPorSerie.count != numeroDeSeries {
                repeticionesPorSerie = Array(repeating: repeticiones, count: numeroDeSeries)
            }
        } else {
            repeticionesPorSerie = []
        }
    }

    private func guardarSerie() {
        guard let ejercicio = ejercicio else { return }

        if tipoSerie == .subiendoPeso {
            for index in 0..<numeroDeSeries {
                let rep = repeticionesPorSerie.indices.contains(index) ? repeticionesPorSerie[index] : repeticiones
                let nuevaSerie = Serie(
                    repeticiones: rep,
                    descripcion: descripcion.isEmpty ? nil : descripcion,
                    ejercicios: ejercicio,
                    tipoSerie: tipoSerie,
                    observaciones: observaciones.isEmpty ? nil : observaciones
                )
                // Devolver la serie creada a través del closure
                onSave(nuevaSerie)
            }
        } else {
            for _ in 0..<numeroDeSeries {
                let nuevaSerie = Serie(
                    repeticiones: repeticiones,
                    descripcion: descripcion.isEmpty ? nil : descripcion,
                    ejercicios: ejercicio,
                    tipoSerie: tipoSerie,
                    observaciones: observaciones.isEmpty ? nil : observaciones
                )
                // Devolver la serie creada a través del closure
                onSave(nuevaSerie)
            }
        }
        dismiss()
    }
}





#Preview {
    CrearSerieView { nuevaSerie in
        // Aquí puedes imprimir la serie o dejar el closure vacío
        print("Serie creada en el preview: \(nuevaSerie)")
    }
}

