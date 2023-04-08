//
//  CategoryListViewModelTests.swift
//  RecipesTests
//
//  Created by Tony Short on 07/04/2023.
//

import CoreData
import SwiftUI
import XCTest

@testable import Recipes

final class CategoryListViewModelTests: XCTestCase {
    var controller: PersistenceController!
    var subject: CategoryListViewModel!

    var container: NSPersistentContainer {
        controller.container
    }
    var context: NSManagedObjectContext {
        container.viewContext
    }

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
        let selectedCategories = [Recipes.Category]()
        let selectedCategoriesBinding: Binding<[Recipes.Category]> = .constant(selectedCategories)
        subject = CategoryListViewModel(viewContext: context, selectedCategories: selectedCategoriesBinding)
    }

    override func tearDownWithError() throws {
        controller = nil
        subject = nil
    }

    func testFilterCategories() throws {
        subject.addCategory(name: "Beef")
        subject.addCategory(name: "Pasta")
        subject.setup()
        XCTAssertEqual(subject.filteredCategories.map { $0.category.name }, ["Beef", "Pasta"])
        subject.updateFilteredCategories(with: "Bee")
        XCTAssertEqual(subject.filteredCategories.map { $0.category.name }, ["Beef"])
    }

    func testToggleCategory() throws {
        subject.addCategory(name: "Beef")
        subject.setup()
        let category = try XCTUnwrap(subject.filteredCategories.first, "Expected a category")
        XCTAssertFalse(category.isSelected)

        subject.toggleCategory(category)
        let toggledCategory = try XCTUnwrap(subject.filteredCategories.first, "Expected a category")
        XCTAssertTrue(toggledCategory.isSelected)

        subject.toggleCategory(toggledCategory)
        let unToggledCategory = try XCTUnwrap(subject.filteredCategories.first, "Expected a category")
        XCTAssertFalse(unToggledCategory.isSelected)
    }
}
