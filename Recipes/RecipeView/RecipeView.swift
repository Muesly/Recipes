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
    @State private var showPlateImagePicker = false
    @State private var showCategoryPicker = false
    @State private var recipePlateImage: UIImage?
    @State private var showStepsImagePicker = false
    @State private var recipeStepsImage: UIImage?
    @FocusState private var recipeNameIsFocused: Bool
    private let viewModel: RecipeViewModel
    private var recipe: Recipe?

    init(viewModel: RecipeViewModel,
         recipe: Recipe? = nil) {
        self.viewModel = viewModel
        self.recipe = recipe
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Recipe Name:")
                    TextField("Enter recipe name", text: $recipeName)
                        .padding(5)
                        .background(Colours.backgroundTertiary)
                        .cornerRadius(10)
                        .focused($recipeNameIsFocused)
                }
                .padding(.top, 10)
                .foregroundColor(Colours.foregroundPrimary)
                HStack {
                    Text("Photo of plate:")
                    if let recipePlateImage {
                        NavigationLink {
                            Image(uiImage: recipePlateImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } label: {
                            Image(uiImage: recipePlateImage)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(10)
                        }
                    } else {
                        Button {
                            showPlateImagePicker = true
                        } label: {
                            Image(systemName: "camera")
                        }
                    }
                }
                HStack {
                    Text("Photo of steps:")
                    if let recipeStepsImage {
                        NavigationLink {
                            Image(uiImage: recipeStepsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } label: {
                            Image(uiImage: recipeStepsImage)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(10)
                        }
                    } else {
                        Button {
                            showStepsImagePicker = true
                        } label: {
                            Image(systemName: "camera")
                        }
                    }
                }
                HStack {
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Text("Categories:")
                                .foregroundColor(Colours.foregroundPrimary)
                            Button {
                                showCategoryPicker = true
                            } label: {
                                Text("Pick...")
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle(recipeName.isEmpty ? "New Recipe" : recipeName)

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
                        if let recipe = recipe {
                            viewModel.editRecipe(recipe: recipe,
                                                 name: recipeName,
                                                 plateImage: recipePlateImage,
                                                 stepsImage: recipeStepsImage)
                        } else {
                            viewModel.addRecipe(name: recipeName,
                                                plateImage: recipePlateImage,
                                                stepsImage: recipeStepsImage)
                        }
                        dismiss()
                    }
                    .disabled(recipeName.isEmpty)
                }
            }
            .background(Colours.backgroundPrimary)
        }
        .padding()
        .background(Colours.backgroundPrimary)
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
        }
        .sheet(isPresented: $showPlateImagePicker) {
            ImagePicker(sourceType: .camera, selectedImage: self.$recipePlateImage)
        }
        .sheet(isPresented: $showStepsImagePicker) {
            ImagePicker(sourceType: .camera, selectedImage: self.$recipeStepsImage)
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryListView(newCategory: "", categories: [])
        }
    }
}
