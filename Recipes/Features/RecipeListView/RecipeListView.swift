//
//  RecipeListView.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import SwiftUI

struct RecipeListView: View {
    @State private var showingAddRecipeView = false
    @State private var showingGenerateRecipeView = false
    @State private var chosenRecipe: Recipe?
    @State private var recipeSearchStr: String = ""
    @FocusState private var recipeSearchStrIsFocused: Bool
    @ObservedObject private var viewModel: RecipeListViewModel

    init(viewModel: RecipeListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Section {
                    TextField("Search for recipe...", text: $recipeSearchStr).textFieldStyle(RecipeTextFieldStyle())
                        .focused($recipeSearchStrIsFocused)
                        .padding()
                    HStack(spacing: 0) {
                        Button {
                            showingGenerateRecipeView = true
                        } label: {
                            Label {
                                Text("Generate a recipe").bold()
                            } icon: {
                                Image(systemName: "text.viewfinder")
                            }
                        }
                        .padding(5)
                        .buttonStyle(.borderedProminent)
                        Button {
                            showingAddRecipeView = true
                        } label: {
                            Label {
                                Text("Add a recipe").bold()
                            } icon: {
                                Image(systemName: "plus")
                            }
                        }
                        .padding(5)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                }
                Section {
                    List {
                        ForEach(viewModel.filteredRecipes) { recipe in
                            Button {
                                chosenRecipe = recipe
                            } label: {
                                RecipeCell(recipe: recipe,
                                           viewModel: viewModel)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Colours.backgroundSecondary)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteItem(atRow: indexSet.first!)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(Colours.foregroundPrimary)
                .background(Colours.backgroundPrimary)
                .sheet(isPresented: $showingGenerateRecipeView,
                       onDismiss: { viewModel.fetchRecipesWithFilter(recipeSearchStr)}) {
                    GenerateRecipeView(viewModel: .init(viewContext: viewModel.viewContext))
                }
                .sheet(isPresented: $showingAddRecipeView,
                       onDismiss: { viewModel.fetchRecipesWithFilter(recipeSearchStr)}) {
                    RecipeView(viewModel: .init(viewContext: viewModel.viewContext))
                }
                .sheet(item: $chosenRecipe,
                       onDismiss: { viewModel.fetchRecipesWithFilter(recipeSearchStr)}) {
                    RecipeView(viewModel: .init(viewContext: viewModel.viewContext),
                               recipe: $0)
                }
                .onAppear {
                    viewModel.fetchRecipesWithFilter("")
                }
                .onChange(of: recipeSearchStr) { searchStr in
                    viewModel.fetchRecipesWithFilter(searchStr)
                }
            }
            .navigationTitle("Recipes")
            .background(Colours.backgroundPrimary)
        }
        .font(.brand)
    }
}

struct RecipeCell: View {
    let recipe: Recipe
    let viewModel: RecipeListViewModel
    @State private var mealPlanButtonIcon: String?

    var body: some View {
        ZStack(alignment: .leading) {
            if let image = recipe.plateImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.25)
            }
            HStack {
                Image(uiImage: recipe.plateImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                Text(recipe.name ?? "")
                if recipe.rating == 5 {
                    Image(systemName: "star.circle.fill")
                        .frame(width: 20)
                }
                Spacer()
                Button {
                    viewModel.addOrRemoveRecipeFromMealPlan(recipe)
                    mealPlanButtonIcon = viewModel.cellMealPlanButtonIcon(for: recipe)
                } label: {
                    Image(systemName: mealPlanButtonIcon ?? viewModel.cellMealPlanButtonIcon(for: recipe))
                }
            }
            .padding(10)
        }.frame(height: 60)
    }
}
