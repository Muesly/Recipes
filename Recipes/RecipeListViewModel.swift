//
//  RecipeListViewModel.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import SwiftUI

class RecipeListViewModel: ObservableObject {
    @Published var filteredRecipes: [Recipe] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchRecipesWithFilter(_ filter: String) {
        let request = Recipe.fetchRequest()

        do {
            let recipes = try context.fetch(request)
            filteredRecipes = recipes.filter { recipe in
                if filter.isEmpty {
                    return true
                }
                if recipe.name!.contains(filter) {
                    return true
                }

                if let categories = recipe.categories,
                   Array(categories).contains(where: { ($0 as? Category)?.name!.contains(filter) ?? false}) {
                    return true
                }

                if let bookName = recipe.book?.name,
                   bookName.contains(filter) {
                    return true
                }

                if (String(recipe.rating) == filter) {
                    return true
                }
                return false
            }
        } catch {
            print("Failed to get recipes")
        }
    }
}
