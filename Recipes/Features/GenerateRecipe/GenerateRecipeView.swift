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
    @State var showingPromptPreview: Bool = false
    @State private var selectedCategories: NSSet = NSSet()
    @State var promptText: String = ""

    init(viewModel: GenerateRecipeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    CategoryPickerView(viewContext: viewModel.viewContext,
                                       labelModifier: LeftAlignedRecipeFormTitleText(),
                                       selectedCategories: $selectedCategories)
                    Spacer()
                    Button {
                        showingPromptPreview = true
                    } label: {
                        Text("Preview prompt")
                    }
                }
                .padding()
                VStack(alignment: .center) {
                    Button {
                        loading = true
                        Task {
                            do {
                                try await viewModel.generateRecipe(promptText: promptText)

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
                            ZStack {
                                Image(uiImage: viewModel.recipeImage ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 240)
                                    .clipped()
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button {
                                            viewModel.rotateImage()
                                        } label: {
                                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                                .foregroundColor(.white)
                                        }
                                        .shadow(radius: 1)
                                        .padding()
                                    }
                                    Spacer()
                                    Text("\(recipe.recipeName)").font(.largeTitle)
                                        .lineLimit(3)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .shadow(radius: 3)
                                        .padding()
                                }
                            }
                            Text("\(recipe.description)")
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            Text("Calories").bold()
                            Text("\(recipe.calories)")
                                .padding(.bottom, 5)
                            Text("Ingredients").bold()
                            Text(" ‣ \(recipe.ingredients.joined(separator: "\n ‣ "))")
                                .padding(.bottom, 5)
                            Text("Method").bold()
                            Text(" ‣ \(recipe.method.joined(separator: "\n ‣ "))")
                                .padding(.bottom, 5)
                        }
                        .padding()
                        VStack {
                            Button {
                                viewModel.saveGeneratedRecipe(categories: selectedCategories)
                                dismiss()
                            } label: {
                                Text("Save to my recipes")
                                    .bold()
                                    .frame(alignment: .center)
                            }.padding()
                        }
                    }
                    Spacer()
                }
                .onAppear {
                    selectedCategories = viewModel.defaultSelectedCategories
                    promptText = viewModel.recipeGenerator.promptText(for: selectedCategories)
                }
                .onChange(of: selectedCategories) { selectedCategories in
                    promptText = viewModel.recipeGenerator.promptText(for: selectedCategories)
                }
                .alert("Failed to find a generated recipe",
                       isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                }
                .sheet(isPresented: $showingPromptPreview) {
                    PromptEditorView(promptText: $promptText)
                }
            }
            .navigationTitle("Hello, Chef")
            .background(Colours.backgroundPrimary)
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

struct LeftAlignedRecipeFormTitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Colours.foregroundSecondary)
    }
}
