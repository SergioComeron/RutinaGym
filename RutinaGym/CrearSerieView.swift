//
//  CrearSerieView.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import SwiftUI
import SwiftData

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
    
    // Closure para devolver la serie creada
    var onSave: (Serie) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles de la Serie")) {
                    Stepper(value: $repeticiones, in: 1...20) {
                        Text("Repeticiones: \(repeticiones)")
                    }
                    
                    TextField("Descripción", text: $descripcion)
                }
                
                Section(header: Text("Tipo de Serie")) {
                    Picker("Tipo de Serie", selection: $tipoSerie) {
                        ForEach(TipoSerie.allCases, id: \.self) { tipo in
                            Text(tipo.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
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
        }
    }
    
    struct SelectorDeEjercicioView: View {
        let ejercicios: [Ejercicio]
        @Binding var ejercicioSeleccionado: Ejercicio?
        @Binding var mostrarSelectorDeEjercicio: Bool

        @State private var grupoSeleccionado: GrupoMuscular = .hombros // Grupo muscular seleccionado por defecto
        private var ejerciciosFiltrados: [Ejercicio] {
            ejercicios.filter { $0.grupoMuscular == grupoSeleccionado }
        }

        var body: some View {
            NavigationView {
                VStack {
                    // Picker para seleccionar el grupo muscular
                    Picker("Grupo Muscular", selection: $grupoSeleccionado) {
                        ForEach(GrupoMuscular.allCases, id: \.self) { grupo in
                            Text(grupo.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Cambiamos a MenuPickerStyle
                    .padding()

                    // Lista de ejercicios filtrados por el grupo muscular seleccionado
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


    
    private func guardarSerie() {
        guard let ejercicio = ejercicio else { return }
        
        let nuevaSerie = Serie(
            repeticiones: repeticiones,
            descripcion: descripcion.isEmpty ? nil : descripcion,
            ejercicios: ejercicio,
            tipoSerie: tipoSerie,
            observaciones: observaciones.isEmpty ? nil : observaciones
        )
        
        // Devolver la serie creada a través del closure
        onSave(nuevaSerie)
        dismiss()
    }
}



#Preview {
    CrearSerieView { nuevaSerie in
        // Aquí puedes imprimir la serie o dejar el closure vacío
        print("Serie creada en el preview: \(nuevaSerie)")
    }
}

