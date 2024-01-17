//
//  RecipeOnDisk.swift
//  Recipes
//
//  Created by Tony Short on 04/11/2023.
//

import Foundation

struct RecipeOnDisk: Codable {

    let recipeDescription: String?
    let ingredients: String?
    let method: String?
    let calories: Int32
    let dateAdded: Date?
    let name: String?
    let plateImageData: Data?
    let stepsImageData: Data?
    let categories: [String]?
    let book: String?
    let page: Int32
    let rating: Int16
    let suggestions: String?

    enum CodingKeys: CodingKey {
        case recipeDescription
        case ingredients
        case method
        case calories
        case dateAdded
        case name
        case plateImageData
        case stepsImageData
        case categories
        case book
        case page
        case rating
        case suggestions
    }
}
