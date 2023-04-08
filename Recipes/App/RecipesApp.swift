//
//  RecipesApp.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import SwiftUI

@main
struct RecipesApp: App {
    let persistenceController = PersistenceController.shared

    var viewContext: NSManagedObjectContext {
        return persistenceController.container.viewContext
    }

    var body: some Scene {
        WindowGroup {
            RecipeListView(viewModel: RecipeListViewModel(viewContext: viewContext))
        }
    }
}
