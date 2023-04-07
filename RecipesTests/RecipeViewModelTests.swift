//
//  RecipeViewModelTests.swift
//  RecipesTests
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import XCTest

@testable import Recipes

final class RecipeViewModelTests: XCTestCase {
    var controller: PersistenceController!
    var subject: RecipeViewModel!
    let exampleRecipeName = "Chilli"
    let exampleImage = UIImage(named: "ThumbnailPlaceholder")

    var container: NSPersistentContainer {
        controller.container
    }
    var context: NSManagedObjectContext {
        container.viewContext
    }

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
        subject = RecipeViewModel(viewContext: context)
    }

    override func tearDownWithError() throws {
        controller = nil
        subject = nil
    }

    func testRecipeTitle() {
        var actualTitle = RecipeViewModel.recipeTitle(for: "")
        XCTAssertEqual(actualTitle, "New Recipe")
        actualTitle = RecipeViewModel.recipeTitle(for: exampleRecipeName)
        XCTAssertEqual(actualTitle, exampleRecipeName)
    }

    private func addRecipe() {
        subject.addOrEditRecipe(recipe: nil,
                                name: exampleRecipeName,
                                plateImage: exampleImage,
                                stepsImage: exampleImage)
    }

    private func getSingleRecipe(name: String) -> Recipe? {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        guard let results = try? context.fetch(fetchRequest) else {
            return nil
        }
        return results.first
    }

    func testAddRecipe() throws {
        addRecipe()
        let actualRecipe = try XCTUnwrap(getSingleRecipe(name: exampleRecipeName), "Expected recipe")
        XCTAssertEqual(actualRecipe.name, exampleRecipeName)
        let exampleImageData = exampleImage?.jpegData(compressionQuality: Recipe.compressionQuality)
        XCTAssertEqual(actualRecipe.plateImageData, exampleImageData)
        XCTAssertEqual(actualRecipe.stepsImageData, exampleImageData)
    }

    func testEditRecipe() throws {
        addRecipe()
        let recipe = try XCTUnwrap(getSingleRecipe(name: exampleRecipeName), "Expected recipe")
        let modifiedRecipeName = "Chilli con carne"
        subject.addOrEditRecipe(recipe: recipe,
                                name: modifiedRecipeName,
                                plateImage: exampleImage,
                                stepsImage: exampleImage)
        let modifiedRecipe = try XCTUnwrap(getSingleRecipe(name: modifiedRecipeName), "Expected modified recipe")
        XCTAssertEqual(modifiedRecipe.name, modifiedRecipeName)
    }
}
