//
//  SuggestionsView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import SwiftUI

struct SuggestionsView: View {
    @State private var placeholder: String
    @Binding private var suggestions: String

    init(suggestions: Binding<String>) {
        self._suggestions = suggestions
        _placeholder = State(initialValue: "e.g. reduce chilli")
    }

    var body: some View {
        HStack(alignment: .top) {
            Text("Suggestions")
                .modifier(RecipeFormTitleText())
                .padding(.top, 7.5)
            ZStack {
                TextEditor(text: $placeholder)
                    .disabled(true)
                TextEditor(text: $suggestions)
                    .opacity(suggestions.isEmpty ? 0.7 : 1)
            }
        }
    }
}
