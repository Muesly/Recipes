//
//  GenerateRecipeViewModel.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import Foundation
import UIKit

class GenerateRecipeViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let recipeGenerator: RecipeGenerating
    @Published var generatedRecipe: GeneratedRecipe? = nil
    private var recipeImageURLs: [URL]?
    private var chosenImageIndex: Int = 0
    @Published var recipeImage: UIImage? = nil

    init(viewContext: NSManagedObjectContext,
         recipeGenerator: RecipeGenerating = RecipeGenerator()) {
        self.viewContext = viewContext
        self.recipeGenerator = recipeGenerator
    }

    func promptText(categories: NSSet) -> String {
        recipeGenerator.promptText(for: categories)
    }

    func generateRecipe(promptText: String) async throws {
        let recipe = try await recipeGenerator.generate(for: promptText)
        await findRecipeImage(recipeName: recipe.recipeName)
        await MainActor.run {
            generatedRecipe = recipe
        }
    }

    func saveGeneratedRecipe(categories: NSSet) {
        guard let generatedRecipe else {
            return
        }

        let recipe = Recipe(context: viewContext,
                            name: generatedRecipe.recipeName)
        recipe.recipeDescription = generatedRecipe.description
        recipe.calories = Int32(generatedRecipe.calories)
        recipe.ingredients = generatedRecipe.ingredients.joined(separator: "\t")
        recipe.method = generatedRecipe.method.joined(separator: "\t")
        recipe.plateImageData = recipeImage?.jpegData(compressionQuality: 0.9)
        recipe.categories = categories

        do {
            try viewContext.save()
        } catch {
            print("Failed to save recipe: \(error)")
        }
    }

    var defaultSelectedCategories: NSSet {
        let request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Dinner")
        return NSSet(array: ((try? viewContext.fetch(request)) ?? []))
    }

    func findRecipeImage(recipeName: String) async {
        let cseId = Bundle.main.infoDictionary!["Google Image API CSE ID"]!
        let apiKey = Bundle.main.infoDictionary!["Google Image API Key"]!
        let name = recipeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        do {
            let urlString = """
            https://www.googleapis.com/customsearch/v1?q=\(name)&cx=\(cseId)&key=\(apiKey)&\
            searchType=image&imgSize=medium&imgType=photo
            """

            let request = URLRequest(url: URL(string: urlString)!)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw NSError(domain: "Invalid HTTP response", code: 0, userInfo: nil)
            }

            let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: data)
            recipeImageURLs = imageResponse.items.compactMap { URL(string: $0.link) }
            chosenImageIndex = 0
            try await loadImage()
        } catch {
            print(error)
        }
    }

    func rotateImage() {
        Task {
            chosenImageIndex += 1
            if chosenImageIndex == recipeImageURLs?.count {
                chosenImageIndex = 0
            }
            try await loadImage()
        }
    }

    private func loadImage() async throws {
        if let firstImageURL = recipeImageURLs?[chosenImageIndex] {
            let request = URLRequest(url: firstImageURL)
            let (imageData, _) = try await URLSession.shared.data(for: request)
            await MainActor.run {
                recipeImage = UIImage(data: imageData)
            }
        }
    }
}

struct ImageResponse: Decodable {
    struct ImageItem: Decodable {
        let link: String
    }

    let items: [ImageItem]
}
