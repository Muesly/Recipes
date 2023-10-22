//
//  Meal.swift
//  Recipes
//
//  Created by Tony Short on 14/04/2023.
//

import CoreData
import Foundation

extension Meal {
    convenience init(viewContext: NSManagedObjectContext,
                     day: String) {
        self.init(context: viewContext)
        self.day = day
    }
}

