//
//  RecipeListView.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import SwiftUI

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddRecipeView = false
    @State private var chosenRecipe: Recipe?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateAdded, ascending: true)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    showingAddRecipeView = true
                } label: {
                    Text("Add a new recipe")
                }
                List {
                    ForEach(recipes) { recipe in
                        Button {
                            chosenRecipe = recipe
                        } label: {
                            HStack {
                                Image(uiImage: UIImage(data: recipe.plateImage ?? Data()) ?? UIImage())
                                    .frame(width: 40, height: 40)
                                Image(uiImage: UIImage(data: recipe.stepsImage ?? Data()) ?? UIImage())
                                    .frame(width: 40, height: 40)
                                Text(recipe.name ?? "")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        self.deleteItem(atRow: indexSet.first!)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                .sheet(isPresented: $showingAddRecipeView) {
                    RecipeView(viewModel: .init(viewContext: viewContext))
                }
                .sheet(item: $chosenRecipe) {
                    RecipeView(viewModel: .init(viewContext: viewContext),
                               recipe: $0)
                }
            }
            .navigationTitle("Recipes")
        }
    }

    private func deleteItem(atRow row: Int) {
        _ = withAnimation {
            Task {
                viewContext.delete(recipes[row])
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save delete")
                }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
