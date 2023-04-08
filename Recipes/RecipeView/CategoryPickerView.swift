//
//  CategoryPickerView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import SwiftUI

struct CategoryPickerView: View {
    @State private var showCategoryPicker = false
    private let title: String
    private let viewContext: NSManagedObjectContext
    private let viewModel: CategoryPickerViewModel
    @Binding private var selectedCategories: NSSet

    init(title: String,
         viewContext: NSManagedObjectContext,
         viewModel: CategoryPickerViewModel,
         selectedCategories: Binding<NSSet>) {
        self.title = title
        self.viewContext = viewContext
        self.viewModel = viewModel
        self._selectedCategories = selectedCategories
    }

    var body: some View {
        HStack {
            Button {
                showCategoryPicker = true
            } label: {
                HStack {
                    Text(title)
                        .modifier(RecipeFormTitleText())
                    Button {
                        showCategoryPicker = true
                    } label: {
                        Text(viewModel.categoriesButtonTitle)
                    }
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryListView(viewModel: CategoryListViewModel(viewContext: viewContext,
                                                              selectedCategories: $selectedCategories))
        }
    }
}

class CategoryPickerViewModel {
    private let recipe: Recipe?

    init(recipe: Recipe?) {
        self.recipe = recipe
    }

    var categoriesButtonTitle: String {
        if let categories = recipe?.categories?.allObjects as? [Category],
           !categories.isEmpty {
            return categories.map { $0.name! }.sorted().joined(separator: ", ")
        } else {
            return "Pick..."
        }
    }
}
