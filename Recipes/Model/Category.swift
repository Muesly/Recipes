//
//  Category.swift
//  Recipes
//
//  Created by Tony Short on 07/04/2023.
//

import CoreData
import Foundation
import UIKit

extension Category {
    convenience init(context: NSManagedObjectContext,
                     name: String) {
        self.init(context: context)
        self.name = name
    }
}
