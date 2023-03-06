//
//  AddRecipeView.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var recipeName: String = ""
    @FocusState private var recipeNameIsFocused: Bool
    private let viewModel: AddRecipeViewModel

    init(viewModel: AddRecipeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TextField("Enter recipe name", text: $recipeName)
                .focused($recipeNameIsFocused)
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem {
                Button("Save") {
                    recipeNameIsFocused = false
                    viewModel.saveRecipe(name: recipeName)
                    dismiss()
                }
                .disabled(recipeName.isEmpty)
            }
        }
        .onAppear {
            recipeNameIsFocused = true
        }
    }
}
