//
//  RecipeListViewModelTests.swift
//  RecipesTests
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import XCTest

@testable import Recipes

final class RecipeListViewModelTests: XCTestCase {
    var controller: PersistenceController!
    var subject: RecipeListViewModel!
    let exampleRecipeName = "Chilli"
    let exampleImage = UIImage(named: "ThumbnailPlaceholder")

    var container: NSPersistentContainer {
        controller.container
    }
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
        subject = RecipeListViewModel(viewContext: viewContext)
    }

    override func tearDownWithError() throws {
        controller = nil
        subject = nil
    }

    private func addRecipe() throws {
        _ = Recipe(context: viewContext,
                   name: exampleRecipeName,
                   plateImage: nil,
                   stepsImage: nil,
                   categories: NSSet(array: [Category(context: viewContext,
                                                      name: "Cat 1")]),
                   book: Book(context: viewContext,
                              name: "Mary Berry"),
                   page: 0,
                   rating: 5,
                   suggestions: "")

        try viewContext.save()
    }

    func testFetchRecipesWithFilters() throws {
        try addRecipe()

        subject.fetchRecipesWithFilter("Doesn't exist")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, [])

        subject.fetchRecipesWithFilter("Chi")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, ["Chilli"])

        subject.fetchRecipesWithFilter("Cat")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, ["Chilli"])

        subject.fetchRecipesWithFilter("Mary")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, ["Chilli"])

        subject.fetchRecipesWithFilter("5")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, ["Chilli"])
    }

    func testDelete() throws {
        try addRecipe()
        subject.fetchRecipesWithFilter("")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, ["Chilli"])
        subject.deleteRecipe(subject.filteredRecipes.first!)
        subject.fetchRecipesWithFilter("")
        XCTAssertEqual(subject.filteredRecipes.map { $0.name }, [])
    }
}

