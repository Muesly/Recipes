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
    let viewContext: NSManagedObjectContext
    private var filter: String = ""

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func fetchRecipesWithFilter(_ filter: String) {
        self.filter = filter
        updateRecipes()
    }

    private func updateRecipes() {
        let request = Recipe.fetchRequest()

        do {
            let recipes = try viewContext.fetch(request)
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
            }.sorted { $0.dateAdded! > $1.dateAdded! }
        } catch {
            print("Failed to get recipes")
        }
    }

    func deleteItem(atRow row: Int) {
        _ = withAnimation {
            Task {
                deleteRecipe(filteredRecipes[row])
            }
        }
    }

    func deleteRecipe(_ recipe: Recipe) {
        viewContext.delete(recipe)
        do {
            try viewContext.save()
        } catch {
            print("Failed to save delete")
        }
    }

    func cellMealPlanButtonIcon(for recipe: Recipe) -> String {
        (recipe.mealPlan != nil) ? "checkmark" : "plus"
    }

    func addOrRemoveRecipeFromMealPlan(_ recipe: Recipe) {
        let request = MealPlan.fetchRequest()

        var mealPlan = try? viewContext.fetch(request).first
        if mealPlan == nil {
            mealPlan = MealPlan(viewContext: viewContext)
        }
        if recipe.mealPlan == nil {
            mealPlan?.addToRecipes(recipe)
        } else {
            mealPlan?.removeFromRecipes(recipe)
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to add recipe to meal plan: \(error)")
        }
    }
}
