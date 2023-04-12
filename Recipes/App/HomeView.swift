//
//  HomeView.swift
//  Recipes
//
//  Created by Tony Short on 12/04/2023.
//

import CoreData
import SwiftUI

struct HomeView: View {
    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    var body: some View {
        TabView {
            RecipeListView(viewModel: RecipeListViewModel(viewContext: viewContext))
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife.circle")
                }
            MealPlannerView()
                .tabItem {
                    Label("Meal Planner", systemImage: "calendar.circle")
                }
            ShoppingListView()
                .tabItem {
                    Label("Shopping List", systemImage: "list.bullet.circle")
                }
        }
    }
}
