//
//  Repository.swift
//  RutinaGym
//
//  Created by Sergio Comerón Sánchez-Pani on 9/10/24.
//

import Foundation

protocol DataRepository {
    var url: URL { get }
}

extension DataRepository {
    func getData() throws -> [Ejercicio] {
        let Data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([EjercicioDTO].self, from: Data).map(\.toEjercicio)
    }
}

struct Repository: DataRepository {
    var url: URL {
        guard let url = Bundle.main.url(forResource: "ejercicios", withExtension: "json") else {
            fatalError("No se pudo encontrar el recurso 'ejercicios.json'")
        }
        return url
    }
}


struct RepositoryTest: DataRepository {
    var url: URL {
        guard let url = Bundle.main.url(forResource: "ejerciciosTest", withExtension: "json") else {
            fatalError("No se pudo encontrar el recurso 'ejerciciosTest.json'")
        }
        return url
    }
}


struct RepositoryWeb: DataRepository {
    var url: URL {
        guard let url = URL(string: "https://sergiocomeron.com/ejercicios.json") else {
            fatalError("No se pudo crear la URL")
        }
        return url
    }
}
