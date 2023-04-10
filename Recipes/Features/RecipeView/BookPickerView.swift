//
//  BookPickerView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import SwiftUI

struct BookPickerView: View {
    @State private var showBookPicker = false
    private let viewModel: BookPickerViewModel
    private let viewContext: NSManagedObjectContext
    @Binding private var selectedBook: Book?
    @Binding private var page: Int32

    init(viewContext: NSManagedObjectContext,
         viewModel: BookPickerViewModel,
         selectedBook: Binding<Book?>,
         page: Binding<Int32>) {
        self.viewContext = viewContext
        self.viewModel = viewModel
        self._selectedBook = selectedBook
        self._page = page
    }

    var body: some View {
        HStack {
            Button {
                showBookPicker = true
            } label: {
                HStack {
                    Text("Book")
                        .modifier(RecipeFormTitleText())
                    Button {
                        showBookPicker = true
                    } label: {
                        Text(viewModel.bookButtonTitle)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .sheet(isPresented: $showBookPicker) {
            BookListView(viewModel: BookListViewModel(viewContext: viewContext),
                         selectedBook: $selectedBook,
                         page: $page)
        }
    }
}

class BookPickerViewModel {
    private let recipe: Recipe?

    init(recipe: Recipe?) {
        self.recipe = recipe
    }

    var bookButtonTitle: String {
        if let book = recipe?.book,
           let page = recipe?.page {
            return "\(book.name!) - Page \(page)"
        } else {
            return "Pick..."
        }
    }
}
