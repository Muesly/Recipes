//
//  GenerateRecipeViewModel.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import Foundation

@MainActor
class GenerateRecipeViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let recipeGenerator: RecipeGenerating
    @Published var generatedRecipe: GeneratedRecipe? = nil

    init(viewContext: NSManagedObjectContext,
         recipeGenerator: RecipeGenerating = RecipeGenerator()) {
        self.viewContext = viewContext
        self.recipeGenerator = recipeGenerator
    }

    func generateRecipe(categories: NSSet) async throws {
        let typeOfMeal = categories.map { ($0 as! Category).name! }.joined(separator: ", ")
        generatedRecipe = try await recipeGenerator.generate(typeOfMeal: typeOfMeal)
    }

    func saveGeneratedRecipe() {
        guard let generatedRecipe else {
            return
        }

        let recipe = Recipe(context: viewContext,
                            name: generatedRecipe.recipeName)
        recipe.recipeDescription = generatedRecipe.description
        recipe.calories = Int32(generatedRecipe.calories)
        recipe.ingredients = generatedRecipe.ingredients.joined(separator: "\t")
        recipe.method = generatedRecipe.method.joined(separator: "\t")

        do {
            try viewContext.save()
        } catch {
            print("Failed to save recipe: \(error)")
        }
    }

    var defaultSelectedCategories: NSSet {
        var request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Dinner")
        return NSSet(array: ((try? viewContext.fetch(request)) ?? []))
    }
}

struct GeneratedRecipe: Decodable {
    let recipeName: String
    let calories: Int
    let description: String
    let ingredients: [String]
    let method: [String]
}

protocol RecipeGenerating {
    func generate(typeOfMeal: String) async throws -> GeneratedRecipe
}

enum RecipeGeneratorError: Error {
    case failedToDecodeRecipeFromResponse
    case failedToFindContentInResponse
    case failedToDecodeRecipeFromGPTSuggestion
}

struct RecipeGenerator: RecipeGenerating {
    let apiKey = "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"

    func generate(typeOfMeal: String) async throws -> GeneratedRecipe {
        let urlString = "https://api.openai.com/v1/chat/completions"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let parameters: [String : Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [[ "role": "user", "content": """
You are a chef. Can you recommend an \(typeOfMeal) recipe to me? \
The meal will be for 2 adults with a modest appetite. \
I would like the measurements to be in metric rather than imperial. \
Answer in JSON with the fields recipeName (as a string), description (as a string), calories (as an integer), ingredients (as an array of strings) and method (as an array of strings)
"""]]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response: GPTResponse
        do {
            response = try decoder.decode(GPTResponse.self, from: data)
        } catch {
            throw RecipeGeneratorError.failedToDecodeRecipeFromResponse
        }
        guard let content = response.content else {
            throw RecipeGeneratorError.failedToFindContentInResponse
        }

        do {
            let recipe = try decoder.decode(GeneratedRecipe.self, from: content.data(using: .utf8)!)
            return recipe
        } catch {
            throw RecipeGeneratorError.failedToDecodeRecipeFromGPTSuggestion
        }
    }
}

struct GPTResponse: Decodable {
    struct GPTMessage: Decodable {
        let content: String
    }

    struct GPTChoice: Decodable {
        let message: GPTMessage
    }
    let choices: [GPTChoice]

    var content: String? {
        choices.first?.message.content
    }
}
