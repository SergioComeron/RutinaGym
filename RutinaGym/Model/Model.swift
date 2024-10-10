//
//  Model.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import Foundation

enum GrupoMuscular: String, CaseIterable, Codable {
    case hombros
    case espalda
    case pecho
    case bíceps
    case tríceps
    case cuádriceps
    case femoral
    case abdomen
    case aductor
    case abductor
    case gluteo
    case gemelo
    case otros // En caso de que haya grupos que no coincidan con las categorías comunes
}

struct EjercicioDTO: Codable {
    let id: Int
    let nombre: String
    let variable: String
    let descripcion: String
    let grupoMuscular: String // Se mantiene como String porque viene del JSON
}

extension EjercicioDTO {
    var toEjercicio: Ejercicio {
        let grupo = GrupoMuscular(rawValue: grupoMuscular.lowercased()) ?? .otros
        return Ejercicio(id: id, nombre: nombre, variable: variable, descripcion: descripcion, grupoMuscular: grupo)
    }
}

struct Ejercicio: Identifiable, Hashable, Codable {
    let id: Int
    let nombre: String
    let variable: String
    let descripcion: String
    let grupoMuscular: GrupoMuscular
}
