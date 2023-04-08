//
//  Book.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import CoreData
import Foundation
import UIKit

extension Book {
    convenience init(context: NSManagedObjectContext,
                     name: String) {
        self.init(context: context)
        self.name = name
    }
}
