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
                TextField("Enter category name", text: $categoryName)
                    .padding(5)
                    .background(Colours.backgroundTertiary)
                    .cornerRadius(10)
                    .focused($categoryNameIsFocused)
                List {
                    ForEach(viewModel.filteredCategories, id: \.self) { categoryWithSelection in
                        HStack {
                            if categoryWithSelection.isSelected {
                                Image(systemName: "checkmark.square")
                            } else {
                                Image(systemName: "square")
                            }
                            Text(categoryWithSelection.category.name ?? "")
                        }
                        .onTapGesture {
                            viewModel.toggleCategory(categoryWithSelection)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteCategories(categoryWithSelectionIndex: indexSet.first!)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .foregroundColor(Colours.foregroundPrimary)
            .background(Colours.backgroundPrimary)
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
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
}
