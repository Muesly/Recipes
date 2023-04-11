//
//  PromptEditorView.swift
//  Recipes
//
//  Created by Tony Short on 10/04/2023.
//

import SwiftUI

struct PromptEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var promptText: String
    @State var promptTextDraft: String = ""

    init(promptText: Binding<String>) {
        self._promptText = promptText
    }

    var body: some View {
        NavigationView {
            TextEditor(text: $promptTextDraft)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            promptText = promptTextDraft
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    self.promptTextDraft = promptText
                }
        }
    }
}
