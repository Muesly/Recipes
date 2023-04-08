//
//  CategoryListViewModel.swift
//  Recipes
//
//  Created by Tony Short on 07/04/2023.
//

import CoreData
import Foundation
import SwiftUI

class CategoryListViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    private var allCategories: [CategoryWithSelection] = [] {
        didSet {
            updateFilteredCategories()
        }
    }

    private var filter: String? {
        didSet {
            updateFilteredCategories()
        }
    }
    @Published var filteredCategories: [CategoryWithSelection] = []
    @Binding var selectedCategories: [Category]

    init(viewContext: NSManagedObjectContext,
         selectedCategories: Binding<[Category]>) {
        self.viewContext = viewContext
        self._selectedCategories = selectedCategories
    }

    func setup() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        guard let results = try? viewContext.fetch(fetchRequest) else {
            return
        }
        allCategories = results.map({ category in
            let isSelected = selectedCategories.contains(where: { selectedCategory in
                selectedCategory.name == category.name
            })
            return CategoryWithSelection(category: category, isSelected: isSelected)
        }).sorted(by: { c1, c2 in
            c1.category.name! < c2.category.name!
        })
    }

    private func updateFilteredCategories() {
        if let filter, !filter.isEmpty {
            filteredCategories = allCategories.filter { $0.category.name!.contains(filter) }
        } else {
            filteredCategories = allCategories
        }
    }

    func updateFilteredCategories(with filter: String) {
        self.filter = filter
    }

    func addCategory(name: String) {
        let category = Category(context: viewContext, name: name)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        allCategories.append(CategoryWithSelection(category: category, isSelected: true))
        allCategories.sort(by: { c1, c2 in
            c1.category.name! < c2.category.name!
        })
    }

    func deleteCategories(categoryWithSelectionIndex: Int) {
        let categoryWithSelection = filteredCategories[categoryWithSelectionIndex]
        viewContext.delete(categoryWithSelection.category)
        do {
            try viewContext.save()
        } catch {
            print("Failed to save delete")
        }
        guard let categoryWithSelectionIndex = allCategories.firstIndex(where: { $0 == categoryWithSelection }) else {
            print("Cannot find category to delete in allCategories")
            return
        }
        allCategories.remove(at: categoryWithSelectionIndex)
    }
    
    func toggleCategory(_ categoryWithSelection: CategoryWithSelection) {
        guard let foundCategoryIndex = allCategories.firstIndex(where: { $0 == categoryWithSelection }) else {
            print("Failed to find category")
            return
        }
        allCategories[foundCategoryIndex].setIsSelected(!allCategories[foundCategoryIndex].isSelected)
        selectedCategories = allCategories.filter { $0.isSelected }.map { $0.category }
    }
}

struct CategoryWithSelection: Hashable {
    let id = UUID()
    let category: Category
    var isSelected: Bool

    mutating func setIsSelected(_ selected: Bool) {
        isSelected = selected
    }
}
