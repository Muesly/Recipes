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

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func fetchRecipesWithFilter(_ filter: String) {
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

    func importRecipes(from url: URL) {
        if url.startAccessingSecurityScopedResource() {
            do {
                let data = try Data(contentsOf: url)
                let recipes = try JSONDecoder().decode([RecipeOnDisk].self, from: data)
                recipes.forEach {
                    let recipe = Recipe(context: viewContext)
                    recipe.recipeDescription = $0.recipeDescription
                    recipe.ingredients = $0.ingredients
                    recipe.method = $0.method
                    recipe.dateAdded = $0.dateAdded ?? Date()
                    recipe.name = $0.name
                    recipe.calories = $0.calories
                    recipe.plateImageData = $0.plateImageData
                    recipe.stepsImageData = $0.stepsImageData
                    do {
                        let categories = try viewContext.fetch(Category.fetchRequest())
                        recipe.categories = NSSet(array: $0.categories?.map { categoryName in
                            if let foundCategory = categories.first(where: { category in
                                category.name == categoryName }) {
                                return foundCategory
                            } else {
                                let newCategory = Category(context: viewContext, name: categoryName)
                                viewContext.insert(newCategory)
                                return newCategory
                            }
                        } ?? [])
                    } catch {
                        print("Failed to find or add category")
                    }

                    if let bookToAdd = $0.book {
                        do {
                            let books = try viewContext.fetch(Book.fetchRequest())
                            if let book = books.first(where: { book in
                                book.name == bookToAdd
                            }) {
                                recipe.book = book
                            } else {
                                recipe.book = Book(context: viewContext, name: bookToAdd)
                                viewContext.insert(Book(context: viewContext, name: bookToAdd))
                            }
                        } catch {
                            print("Failed to find or add book")
                        }
                    }
                    recipe.page = $0.page
                    recipe.rating = $0.rating
                    recipe.suggestions = $0.suggestions
                }
                try viewContext.save()
                fetchRecipesWithFilter("")
            } catch {
                print("Failed to decode recipes: \(error)")
            }
            url.stopAccessingSecurityScopedResource()
        }
    }

    func recipesAsJSON() -> URL? {
        let request = Recipe.fetchRequest()
        do {
            let recipes = try viewContext.fetch(request)
            let recipesJSON = try JSONEncoder().encode(recipes.map {
                RecipeOnDisk(recipeDescription: $0.recipeDescription,
                             ingredients: $0.ingredients,
                             method: $0.method,
                             calories: $0.calories,
                             dateAdded: $0.dateAdded,
                             name: $0.name,
                             plateImageData: $0.plateImageData,
                             stepsImageData: $0.stepsImageData,
                             categories: ($0.categories?.allObjects as? [Category])?.map {
                                category in
                                category.name ?? ""
                            },
                             book: $0.book?.name,
                             page: $0.page,
                             rating: $0.rating,
                             suggestions: $0.suggestions) })

            let filename = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("recipes.json")!
            try recipesJSON.write(to: filename)
            return filename
        } catch {
            print("Failed to fetch or encode recipes: \(error)")
            return nil
        }
    }
}
