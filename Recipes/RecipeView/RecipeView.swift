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
            VStack(alignment: .center, spacing: 20) {
                TextField("Enter recipe name", text: $recipeName)
                    .focused($recipeNameIsFocused)
                    .padding(.top, 20)
                Button {
                    showPlateImagePicker = true
                } label: {
                    HStack {
                        Text("Take photo of plate")
                        Image(systemName: "camera")
                    }
                }
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
                    }
                }
                Button {
                    showStepsImagePicker = true
                } label: {
                    HStack {
                        Text("Take photo of recipe steps")
                        Image(systemName: "camera")
                    }
                }
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
                    }
                }
                Spacer()
            }
            .padding()
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
        }
        .onAppear {
            recipeNameIsFocused = true

            guard let recipe = recipe,
                  let name = recipe.name else {
                return
            }
            recipeName = name
            if let plateImageData = recipe.plateImage,
               let plateImage = UIImage(data: plateImageData) {
                recipePlateImage = plateImage
            }
            if let stepsImageData = recipe.stepsImage,
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
    }
}
