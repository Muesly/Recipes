//
//  MealPlan.swift
//  Recipes
//
//  Created by Tony Short on 14/04/2023.
//

import CoreData
import Foundation
import UIKit

extension MealPlan {
    convenience init(viewContext: NSManagedObjectContext) {
        self.init(context: viewContext)
        for day in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] {
            let meal = Meal(viewContext: viewContext, day: day)
            meal.mealPlan = self
        }
    }

    func mealForDay(_ day: String) -> Meal? {
        let meals = self.meals?.allObjects as? [Meal]
        return meals?.first { $0.day == day }
    }
}
