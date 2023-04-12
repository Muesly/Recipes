//
//  GenerateRecipeViewModelTests.swift
//  RecipesTests
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import XCTest

@testable import Recipes

class GenerateRecipeViewModelTests: XCTest {
    var controller: PersistenceController!
    var subject: GenerateRecipeViewModel!
    var mockRecipeGenerator: MockRecipeGenerator!

    var container: NSPersistentContainer {
        controller.container
    }
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
        mockRecipeGenerator = MockRecipeGenerator()
        subject = GenerateRecipeViewModel(viewContext: viewContext,
                                          recipeGenerator: mockRecipeGenerator)
    }

    override func tearDownWithError() throws {
        controller = nil
        subject = nil
    }

    func testGeneratingARecipe() async throws {
        mockRecipeGenerator.generatedName = "Generated Recipe"
        try await subject.generateRecipe(promptText: "Test")
        XCTAssertEqual(subject.generatedRecipe?.recipeName, "Generated Recipe")
    }
}

struct MockRecipeGenerator: RecipeGenerating {
    func promptText(for categories: NSSet) -> String {
        return ""
    }

    func generate(for promptText: String) async throws -> Recipes.GeneratedRecipe {
        return GeneratedRecipe(recipeName: "", calories: 0, description: "", ingredients: [], method: [])
    }

    var generatedName: String?
}
