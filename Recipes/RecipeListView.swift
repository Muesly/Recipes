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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateAdded, ascending: true)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>

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
                        Text("Add a new recipe")
                            .bold()
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

    private func deleteItem(atRow row: Int) {
        _ = withAnimation {
            Task {
                viewModel.viewContext.delete(recipes[row])
                do {
                    try viewModel.viewContext.save()
                } catch {
                    print("Failed to save delete")
                }
            }
        }
    }

    private func load() {
        if let path = Bundle.main.path(forResource: "recipes", ofType: "tsv") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myRecipes = data.components(separatedBy: .newlines)
                var first = true
                for recipe in myRecipes {
                    if first {
                        first = false
                        continue
                    }
                    let recipeComponents = recipe.split(separator: "\t")
                    if recipeComponents.count < 6 {
                        continue
                    }
                    let name = String(recipeComponents[0])
                    let book = recipeComponents[1]
                    let page = Int32(recipeComponents[2])!
                    let categories = recipeComponents[3].trimmingCharacters(in: CharacterSet(charactersIn: "\"")).split(separator: " , ")
                    let rating = Int16(recipeComponents[4])!
                    var suggestions = String(recipeComponents[5])
                    if Int(suggestions) ?? 0 > 0 {
                        suggestions = ""
                    }
                    let recipe = Recipe(context: viewModel.viewContext, name: name, plateImage: nil, stepsImage: nil)
                    recipe.page = page
                    recipe.rating = rating

                    for category in categories {
                        let request = Category.fetchRequest()
                        request.predicate = NSPredicate(format: "name == %@", category as CVarArg)
                        var foundCategory: Category?
                        if let result = try? viewModel.viewContext.fetch(request),
                           result.count == 1 {
                            foundCategory = result.first
                        } else {
                            foundCategory = Category(context: viewContext, name: String(category))
                        }
                        recipe.addToCategories(foundCategory!)
                    }

                    let bookRequest = Book.fetchRequest()
                    let request = Book.fetchRequest()
                    request.predicate = NSPredicate(format: "name == %@", book as CVarArg)
                    var foundBook: Book?
                    if let result = try? viewModel.viewContext.fetch(request),
                       result.count == 1 {
                        foundBook = result.first
                    } else {
                        foundBook = Book(context: viewModel.viewContext, name: String(book))
                    }
                    recipe.book = foundBook
                    recipe.suggestions = suggestions
                }
                do {
                    try viewModel.viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            } catch {
                print(error)
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
