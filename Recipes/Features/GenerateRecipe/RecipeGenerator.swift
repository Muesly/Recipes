//
//  RecipeGenerator.swift
//  Recipes
//
//  Created by Tony Short on 10/04/2023.
//

import Foundation

protocol RecipeGenerating {
    func promptText(for categories: NSSet) -> String
    func generate(for promptText: String) async throws -> GeneratedRecipe
}

enum RecipeGeneratorError: Error {
    case failedToDecodeRecipeFromResponse
    case failedToFindContentInResponse
    case failedToDecodeRecipeFromGPTSuggestion
}

struct RecipeGenerator: RecipeGenerating {
    func promptText(for categories: NSSet) -> String {
        let typeOfMeal = categories.map { ($0 as! Category).name! }.joined(separator: ", ")

        return """
        You are a chef. Can you recommend a \(typeOfMeal) recipe to me? \
        The meal will be for 2 adults with a modest appetite, and shouldn't contain pine nuts or pesto. \
        Answer in JSON with the fields recipeName (as a string), description (as a string), calories (as an integer), ingredients (as an array of strings, using ml rather than cups as a unit of measure) and method (as an array of strings, prefixed with the index number starting from 1)
        """
    }

    func generate(for promptText: String) async throws -> GeneratedRecipe {
        let apiKey = Bundle.main.infoDictionary!["GPT API Key"]!
        let urlString = "https://api.openai.com/v1/chat/completions"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        let parameters: [String : Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [[ "role": "user", "content": promptText]]
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

struct GeneratedRecipe: Decodable {
    let recipeName: String
    let calories: Int
    let description: String
    let ingredients: [String]
    let method: [String]
}
