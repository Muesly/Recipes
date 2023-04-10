//
//  CategoryPickerView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import SwiftUI

struct CategoryPickerView<V>: View where V: ViewModifier {
    @State private var showCategoryPicker = false
    private let viewContext: NSManagedObjectContext
    private let labelModifier: V
    @Binding private var selectedCategories: NSSet

    init(viewContext: NSManagedObjectContext,
         labelModifier: V,
         selectedCategories: Binding<NSSet>) {
        self.viewContext = viewContext
        self.labelModifier = labelModifier
        self._selectedCategories = selectedCategories
    }

    var body: some View {
        HStack {
            Button {
                showCategoryPicker = true
            } label: {
                HStack {
                    Text("Categories")
                        .modifier(labelModifier)
                    Button {
                        showCategoryPicker = true
                    } label: {
                        Text(categoriesButtonTitle)
                    }
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryListView(viewModel: CategoryListViewModel(viewContext: viewContext,
                                                              selectedCategories: $selectedCategories))
        }
    }

    private var categoriesButtonTitle: String {
        if Array(selectedCategories).isEmpty {
            return "Pick..."
        } else {
            return selectedCategories.map { ($0 as! Category).name! }.sorted().joined(separator: ", ")
        }
    }
}
