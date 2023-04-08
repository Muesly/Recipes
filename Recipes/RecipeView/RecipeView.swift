//
//  RecipeView.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import SwiftUI

struct RecipeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var recipeName: String = ""
    @State private var page: Int32 = 0
    @FocusState private var recipeNameIsFocused: Bool
    private let viewModel: RecipeViewModel
    private var recipe: Recipe?
    @State private var recipePlateImage: UIImage?
    @State private var recipeStepsImage: UIImage?
    @State private var categories: NSSet = NSSet()
    @State private var book: Book?
    @State private var rating: Int16 = 4
    @State private var suggestions: String = ""

    init(viewModel: RecipeViewModel,
         recipe: Recipe? = nil) {
        self.viewModel = viewModel
        self.recipe = recipe
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Recipe Name").modifier(RecipeFormTitleText())
                    TextField("Enter recipe name", text: $recipeName).textFieldStyle(RecipeTextFieldStyle())
                        .focused($recipeNameIsFocused)
                }
                .padding(.top, 10)
                .foregroundColor(Colours.foregroundPrimary)
                ImagePickerView(title: "Photo of plate", image: $recipePlateImage)
                ImagePickerView(title: "Photo of steps", image: $recipeStepsImage)
                CategoryPickerView(title: "Categories",
                                   viewContext: viewModel.viewContext,
                                   viewModel: CategoryPickerViewModel(recipe: recipe),
                                   selectedCategories: $categories)
                BookPickerView(title: "Book",
                               viewContext: viewModel.viewContext,
                               viewModel: BookPickerViewModel(recipe: recipe),
                               selectedBook: $book,
                               page: $page)
                RatingView(rating: $rating)
                SuggestionsView(suggestions: $suggestions)
            }
            .navigationTitle(RecipeViewModel.recipeTitle(for: recipeName))

            .padding()
            .cornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        recipeNameIsFocused = false
                        viewModel.addOrEditRecipe(recipe: recipe,
                                                  name: recipeName,
                                                  plateImage: recipePlateImage,
                                                  stepsImage: recipeStepsImage,
                                                  categories: categories,
                                                  book: book,
                                                  page: page,
                                                  rating: rating,
                                                  suggestions: suggestions)
                        dismiss()
                    }
                    .disabled(recipeName.isEmpty)
                }
            }
            .background(Colours.backgroundPrimary)
        }
        .padding()
        .background(Colours.backgroundPrimary)
        .font(.brand)
        .onAppear {
            guard let recipe = recipe,
                  let name = recipe.name else {
                recipeNameIsFocused = true
                return
            }
            recipeName = name
            if let plateImageData = recipe.plateImageData,
               let plateImage = UIImage(data: plateImageData) {
                recipePlateImage = plateImage
            }
            if let stepsImageData = recipe.stepsImageData,
               let stepsImage = UIImage(data: stepsImageData) {
                recipeStepsImage = stepsImage
            }
            categories = recipe.categories ?? NSSet()
            book = recipe.book
            page = recipe.page
            rating = recipe.rating
            suggestions = recipe.suggestions ?? ""
        }
        .onChange(of: categories) { categories in
            recipe?.categories = categories
        }
        .onChange(of: book) { book in
            recipe?.book = book
        }
        .onChange(of: page) { page in
            recipe?.page = page
        }
    }
}

struct RecipeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(Colours.foregroundPrimary)
            .padding(5)
            .background(Colours.backgroundSecondary)
            .cornerRadius(10)
    }
}

struct RecipeFormTitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Colours.foregroundSecondary).opacity(0.7)
            .frame(width: 120, alignment: .trailing)
            .padding(.trailing, 10)
    }
}
