//
//  ShoppingListView.swift
//  Recipes
//
//  Created by Tony Short on 12/04/2023.
//

import SwiftUI

struct ShoppingListView: View {
    @State private var ingredientSearchStr: String = ""
    @FocusState private var ingredientSearchStrIsFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                TextField("Add to shopping list...", text: $ingredientSearchStr).textFieldStyle(RecipeTextFieldStyle())
                    .focused($ingredientSearchStrIsFocused)
                    .padding()
                
                List {
                    Section("Fruit & Veg") {
                        Text("Bananas")
                        Text("Grapes")
                    }
                    Section("Refrigerated Aisles") {
                        Text("Milk")
                        Text("Bread")
                    }
                    Section("Cupboard Aisles") {
                        Text("Eggs")
                    }
                    Section("Household Aisles") {
                        Text("Eggs")
                    }
                }
            }
            .navigationTitle("Shopping List")
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
