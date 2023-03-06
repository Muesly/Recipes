//
//  RecipesApp.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import SwiftUI

@main
struct RecipesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RecipesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
