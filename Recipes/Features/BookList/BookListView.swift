//
//  BookListView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import SwiftUI

struct BookListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: BookListViewModel
    @Binding private var selectedBook: Book?
    @Binding private var page: Int32
    @State private var bookName: String = ""
    @FocusState private var bookNameIsFocused: Bool
    @FocusState private var pageIsFocused: Bool

    init(viewModel: BookListViewModel,
         selectedBook: Binding<Book?>,
         page: Binding<Int32>) {
        self.viewModel = viewModel
        self._selectedBook = selectedBook
        self._page = page
    }

    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Filter or enter new book name", text: $bookName).textFieldStyle(RecipeTextFieldStyle())
                    .focused($bookNameIsFocused)
                    .padding()
                List {
                    Section {
                        ForEach(viewModel.filteredBooks, id: \.self) { book in
                            HStack {
                                Image(systemName: book == selectedBook ? "checkmark.circle" : "circle")
                                Text(book.name ?? "")
                            }
                            .onTapGesture {
                                selectedBook = book
                                dismiss()
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteBook(bookIndex: indexSet.first!)
                        }
                        .listRowBackground(Colours.backgroundSecondary)
                    } header: {
                        Text("Pick an existing book").foregroundColor(Colours.foregroundSecondary)
                    }
                }
                HStack {
                    Text("Page:")
                    TextField("Enter page number", value: $page, formatter: numberFormatter).textFieldStyle(RecipeTextFieldStyle())
                        .keyboardType(.numberPad)
                        .focused($pageIsFocused)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .foregroundColor(Colours.foregroundPrimary)
        .background(Colours.backgroundPrimary)
        .onSubmit {
            if !bookName.isEmpty {
                viewModel.addBook(name: bookName)
                viewModel.updateFilteredBooks(with: "")
                bookName = ""
            }
        }
        .onChange(of: bookName) { name in
            viewModel.updateFilteredBooks(with: name)
        }
    }
}

