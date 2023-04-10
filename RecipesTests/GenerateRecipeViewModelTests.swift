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

    func testGeneratingARecipe() throws {
        mockRecipeGenerator.generatedName = "Generated Recipe"
        let recipe = try XCTUnwrap(subject.generateRecipe())
        XCTAssertEqual(recipe.name, "Generated Recipe")
    }
}

struct MockRecipeGenerator: RecipeGenerating {
    var generatedName: String?

    func generate() -> GeneratedRecipe {
        return .init(name: generatedName!)
    }
}
