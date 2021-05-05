//
//  Pokemon.swift
//  Pokedex
//
//  Created by Rick Jacobson on 4/24/21.
//

import Foundation

struct PokemonResult: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}

struct Pokemon: Decodable {
    var name: String
    var url: String
}

struct PokemonData: Decodable {
    let id: Int
    let name: String
    let sprites: Sprites?
}

struct Sprites: Decodable {
    let frontDefault: String
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
