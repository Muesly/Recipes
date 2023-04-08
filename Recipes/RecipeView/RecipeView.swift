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
    @State private var showCategoryPicker = false
    @FocusState private var recipeNameIsFocused: Bool
    private let viewModel: RecipeViewModel
    private var recipe: Recipe?
    @State private var recipePlateImage: UIImage?
    @State private var recipeStepsImage: UIImage?
    @State private var selectedCategories: [Category] = []

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
                        .background(Colours.backgroundSecondary)
                        .cornerRadius(10)
                        .focused($recipeNameIsFocused)
                }
                .padding(.top, 10)
                .foregroundColor(Colours.foregroundPrimary)
                ImagePickerView(title: "Photo of plate:", image: $recipePlateImage)
                ImagePickerView(title: "Photo of steps:", image: $recipeStepsImage)
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
                                Text(viewModel.categoriesButtonTitle(for: recipe))
                            }
                        }
                    }
                }
                Spacer()
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
                                                  stepsImage: recipeStepsImage)
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
            selectedCategories = (recipe.categories?.allObjects as? [Category]) ?? []
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryListView(viewModel: CategoryListViewModel(viewContext: viewModel.viewContext,
                                                              selectedCategories: $selectedCategories))
        }
        .onChange(of: selectedCategories) { selectedCategories in
            recipe?.categories = NSSet(array: selectedCategories)
            print("Changing selected categories to \(selectedCategories.map {$0.name})")
        }
    }
}

struct ImagePickerView: View {
    let title: String
    @Binding private var image: UIImage?
    @State private var actionSheetShown = false
    @State private var fullScreenImageShown = false
    @State private var takeAPhotoOption = false
    @State private var chooseFromLibraryOption = false

    init(title: String, image: Binding<UIImage?>) {
        self.title = title
        _image = image
    }

    var body: some View {
        HStack {
            Text(title)
            Button {
                if image == nil {
                    actionSheetShown = true
                } else {
                    fullScreenImageShown = true
                }
            } label: {
                Image(uiImage: image ?? UIImage(named: "ThumbnailPlaceholder")!)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(10)
            }
            if image != nil {
                Button {
                    self.image = nil
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Select an option", isPresented: $actionSheetShown, titleVisibility: .hidden) {
            Button("Take a photo") {
                takeAPhotoOption = true
            }
            Button("Choose from library") {
                chooseFromLibraryOption = true
            }
        }
        .sheet(isPresented: $takeAPhotoOption) {
            ImagePicker(sourceType: .camera, selectedImage: self.$image)
        }
        .sheet(isPresented: $chooseFromLibraryOption) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
        .sheet(isPresented: $fullScreenImageShown) {
            PhotoView(image: self.image!)
        }
    }
}
