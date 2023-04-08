//
//  BookListViewModel.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import Foundation
import SwiftUI

class BookListViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    private var allBooks: [Book] = [] {
        didSet {
            updateFilteredBooks()
        }
    }

    private var filter: String? {
        didSet {
            updateFilteredBooks()
        }
    }
    @Published var filteredBooks: [Book] = []

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext

        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        guard let results = try? viewContext.fetch(fetchRequest) else {
            return
        }
        allBooks = results.sorted { $0.name! < $1.name! }
    }

    private func updateFilteredBooks() {
        if let filter, !filter.isEmpty {
            filteredBooks = allBooks.filter { $0.name!.contains(filter) }
        } else {
            filteredBooks = allBooks
        }
    }

    func updateFilteredBooks(with filter: String) {
        self.filter = filter
    }

    func addBook(name: String) {
        let book = Book(context: viewContext, name: name)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        allBooks.append(book)
        allBooks.sort { $0.name! < $1.name! }
    }

    func deleteBook(bookIndex: Int) {
        let book = filteredBooks[bookIndex]
        viewContext.delete(book)
        do {
            try viewContext.save()
        } catch {
            print("Failed to save delete")
        }
        guard let bookIndex = allBooks.firstIndex(where: { $0 == book }) else {
            print("Cannot find category to delete in allCategories")
            return
        }
        allBooks.remove(at: bookIndex)
    }
}
