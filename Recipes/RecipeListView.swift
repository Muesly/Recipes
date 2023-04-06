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
            VStack(alignment: .center) {
                Section {
                    Button {
                        showingAddRecipeView = true
                    } label: {
                        Text("Add a new recipe")
                            .bold()
                    }
                    .padding(5)
                    .buttonStyle(.borderedProminent)
                    .padding(5)
                }
                Section {
                    List {
                        ForEach(recipes) { recipe in
                            Button {
                                chosenRecipe = recipe
                            } label: {
                                HStack {
                                    ThumbnailImageView(uiImage: recipe.plateImage)
                                    Text(recipe.name ?? "")
                                }
                            }
                            .listRowBackground(Colours.backgroundSecondary)
                        }
                        .onDelete { indexSet in
                            self.deleteItem(atRow: indexSet.first!)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(Colours.foregroundPrimary)
                .background(Colours.backgroundPrimary)
                .sheet(isPresented: $showingAddRecipeView) {
                    RecipeView(viewModel: .init(viewContext: viewContext))
                }
                .sheet(item: $chosenRecipe) {
                    RecipeView(viewModel: .init(viewContext: viewContext),
                               recipe: $0)
                }
            }
            .navigationTitle("Recipes")
            .background(Colours.backgroundPrimary)
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

struct ThumbnailImageView: View {
    let uiImage: UIImage?

    var body: some View {
        Image(uiImage: uiImage ?? UIImage(named: "ThumbnailPlaceholder")!)
            .resizable()
            .frame(width: 40, height: 40)
            .cornerRadius(5)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
