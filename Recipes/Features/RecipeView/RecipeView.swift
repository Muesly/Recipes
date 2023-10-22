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
    @FocusState private var recipeNameIsFocused: Bool
    @State private var calories: Int32 = 0
    @FocusState private var caloriesIsFocused: Bool
    @State private var page: Int32 = 0
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

        // Resizes naviation bar title
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Recipe Name").modifier(RecipeFormTitleText())
                        TextField("Enter recipe name", text: $recipeName).textFieldStyle(RecipeTextFieldStyle())
                            .focused($recipeNameIsFocused)
                    }
                    .padding(.top, 10)
                    .foregroundColor(Colours.foregroundPrimary)
                    ImagePickerView(title: "Photo of plate", image: $recipePlateImage)
                    if let recipe,
                       recipe.isGenerated,
                       let ingredients = recipe.ingredients,
                       let method = recipe.method,
                       let recipeDescription = recipe.recipeDescription {
                        Text("\(recipeDescription)")
                            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        Text("Calories").bold()
                        Text("\(recipe.calories)")
                            .padding(.bottom, 5)
                        Text("Ingredients").bold()
                        Text(" ‣ \(ingredients.split(separator: "\t").joined(separator: "\n ‣ "))")
                            .padding(.bottom, 5)
                        Text("Method").bold()
                        Text(" ‣ \(method.split(separator: "\t").joined(separator: "\n ‣ "))")
                            .padding(.bottom, 5)
                    } else {
                        ImagePickerView(title: "Photo of steps", image: $recipeStepsImage)
                        HStack {
                            Text("Calories").modifier(RecipeFormTitleText())
                            TextField("Enter calories per portion", value: $calories, formatter: numberFormatter).textFieldStyle(RecipeTextFieldStyle())
                                .frame(width: 100)
                                .keyboardType(.numberPad)
                                .focused($caloriesIsFocused)
                        }
                    }
                    SuggestionsView(suggestions: $suggestions)
                    CategoryPickerView(viewContext: viewModel.viewContext,
                                       labelModifier: RecipeFormTitleText(),
                                       selectedCategories: $categories)
                    if (recipe == nil) || !recipe!.isGenerated {
                        BookPickerView(viewContext: viewModel.viewContext,
                                       viewModel: BookPickerViewModel(recipe: recipe),
                                       selectedBook: $book,
                                       page: $page)
                    }
                    RatingView(rating: $rating)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(RecipeViewModel.recipeTitle(for: recipeName))
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
                                                  calories: calories,
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
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Colours.backgroundPrimary)
        }
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
            calories = recipe.calories
            categories = recipe.categories ?? NSSet()
            book = recipe.book
            page = recipe.page
            rating = recipe.rating
            suggestions = recipe.suggestions ?? ""
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
