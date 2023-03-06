//
//  RecipesView.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import SwiftUI

struct RecipesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateAdded, ascending: true)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    AddRecipeView(viewModel: .init(viewContext: viewContext))
                } label: {
                    Text("Add a new recipe")
                }
                List {
                    ForEach(recipes) { recipe in
                        NavigationLink {
                            Text("Recipe at \(recipe.dateAdded!, formatter: itemFormatter)")
                        } label: {
                            Text(recipe.name ?? "")
                        }
                    }
//                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
