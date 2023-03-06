//
//  Recipe.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import Foundation

extension Recipe {
    convenience init(context: NSManagedObjectContext,
                     name: String) {
        self.init(context: context)
        self.dateAdded = Date()
        self.name = name
    }
}
