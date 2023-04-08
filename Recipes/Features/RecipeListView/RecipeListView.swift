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
                    Button {
                        showingAddRecipeView = true
                    } label: {
                        Text("Add a new recipe").bold()
                    }
                    .padding(5)
                    .buttonStyle(.borderedProminent)
                    .padding(5)
                }
                Section {
                    List {
                        ForEach(viewModel.filteredRecipes) { recipe in
                            Button {
                                chosenRecipe = recipe
                            } label: {
                                HStack {
                                    Image(uiImage: recipe.plateImage ?? UIImage(named: "ThumbnailPlaceholder")!)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(5)
                                    Text(recipe.name ?? "")
                                }
                            }
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
                .sheet(isPresented: $showingAddRecipeView) {
                    RecipeView(viewModel: .init(viewContext: viewModel.viewContext))
                }
                .sheet(item: $chosenRecipe) {
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
