//
//  GenerateRecipeView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import SwiftUI

struct GenerateRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: GenerateRecipeViewModel
    @State var loading: Bool = false
    @State var showingError: Bool = false

    init(viewModel: GenerateRecipeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center) {
                    Button {
                        Task {
                            do {
                                loading = true
                                try await viewModel.generateRecipe()
                                loading = false
                            } catch {
                                showingError = true
                            }
                        }
                    } label: {
                        if loading {
                            ProgressView()
                        } else {
                            Text("Generate me a Recipe")
                        }
                    }
                    .padding(5)
                    .buttonStyle(.borderedProminent)
                    .padding()
                    if let recipe = viewModel.generatedRecipe {
                        VStack(alignment: .leading) {
                            Text("\(recipe.recipeName)").bold()
                            Text("\(recipe.description)")
                            Text("Calories").bold()
                            Text("\(recipe.calories)")
                            Text("Ingredients").bold()
                            Text(" ‣ \(recipe.ingredients.joined(separator: "\n ‣ "))")
                            Text("Method").bold()
                            Text(" ‣ \(recipe.method.joined(separator: "\n ‣ "))")
                        }
                        .padding()
                        VStack {
                            Button {
                                print("Will find an image")
                            } label: {
                                Text("Find an image")
                                    .bold()
                                    .frame(alignment: .center)
                            }.padding()
                            Button {
                                viewModel.saveGeneratedRecipe()
                            } label: {
                                Text("Save to my recipes")
                                    .bold()
                                    .frame(alignment: .center)
                            }.padding()
                        }
                    }
                    Spacer()
                }
                .navigationTitle("Hello, Chef")
                .background(Colours.backgroundPrimary)
                .alert("Failed to find a generated recipe",
                       isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .font(.brand)
    }
}
