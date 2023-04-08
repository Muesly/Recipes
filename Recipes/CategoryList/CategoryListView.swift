//
//  CategoryListView.swift
//  Recipes
//
//  Created by Tony Short on 07/03/2023.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: CategoryListViewModel

    @State private var categoryName: String = ""
    @FocusState private var categoryNameIsFocused: Bool

    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        viewModel.setup()
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Filter or enter new category name", text: $categoryName).textFieldStyle(RecipeTextFieldStyle())
                    .padding()
                    .focused($categoryNameIsFocused)
                List {
                    Section {
                        ForEach(viewModel.filteredCategories, id: \.self) { categoryWithSelection in
                            HStack {
                                Image(systemName: categoryWithSelection.isSelected ? "checkmark.square" : "square")
                                Text(categoryWithSelection.category.name ?? "")
                            }
                            .onTapGesture {
                                viewModel.toggleCategory(categoryWithSelection)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteCategories(categoryWithSelectionIndex: indexSet.first!)
                        }
                        .listRowBackground(Colours.backgroundSecondary)
                    } header: {
                        Text("Pick an existing category").foregroundColor(Colours.foregroundSecondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .status) {
                    Text(viewModel.categoriesSelectedTitle)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .foregroundColor(Colours.foregroundPrimary)
        .background(Colours.backgroundPrimary)
        .onSubmit {
            viewModel.addCategory(name: categoryName)
            viewModel.updateFilteredCategories(with: "")
            categoryName = ""
        }
        .onChange(of: categoryName) { name in
            viewModel.updateFilteredCategories(with: name)
        }
    }
}

