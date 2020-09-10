//
//  Models.swift
//  product_homemade_recipe
//
//  Created by M'haimdat omar on 09-09-2020.
//

import Foundation

struct Product: Codable {
    let id: String
    let name: String
    let list: [RecipeItem]
}

struct RecipeItem: Codable {
    let quantity: Float
    let product: String
}

