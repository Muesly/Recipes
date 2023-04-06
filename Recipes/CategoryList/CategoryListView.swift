//
//  CategoryListView.swift
//  Recipes
//
//  Created by Tony Short on 07/03/2023.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.dismiss) var dismiss
    @State var newCategory: String = ""
    @State var categories: [String]
    @State private var showNewCategoryView = false
    @State var selectedItems = Set<String>()

    var body: some View {
        NavigationView {
            VStack {
                Button {
                    showNewCategoryView = true
                } label: {
                    Text("Add a new category")
                }
                .padding()
                List(categories, id: \.self, selection: $selectedItems) { (item : String) in

                    let s = selectedItems.contains(item) ? "√" : " "
                    HStack {
                        Text(s+item)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedItems.contains(item) {
                            selectedItems.remove(item)
                        }
                        else{
                            selectedItems.insert(item)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Colours.backgroundSecondary)
            }
            .scrollContentBackground(.hidden)
            .foregroundColor(Colours.foregroundPrimary)
            .background(Colours.backgroundSecondary)
            .cornerRadius(20)
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onChange(of: newCategory) { category in
                categories.append(category)
            }
        }
        .sheet(isPresented: $showNewCategoryView) {
            AddCategoryView(newCategory: $newCategory)
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @State var category: String = ""
    @Binding var newCategory: String
    @FocusState private var categoryIsFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Category:")
                    TextField("Enter category", text: $category)
                        .padding(5)
                        .background(Colours.backgroundTertiary)
                        .cornerRadius(10)
                        .focused($categoryIsFocused)
                }
                .padding()
                Spacer()
            }
            .foregroundColor(Colours.foregroundPrimary)
            .background(Colours.backgroundSecondary)
            .cornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        newCategory = category
                        dismiss()
                    }
                    .disabled(category.isEmpty)
                }
            }
            .onAppear {
                categoryIsFocused = true
            }
        }
    }
}
