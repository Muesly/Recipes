//
//  Recipe.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import CoreData
import Foundation
import UIKit

extension Recipe {
    convenience init(context: NSManagedObjectContext,
                     name: String,
                     plateImage: UIImage,
                     stepsImage: UIImage) {
        self.init(context: context)
        self.dateAdded = Date()
        self.name = name
        self.plateImage = plateImage.jpegData(compressionQuality: 0.9)
        self.stepsImage = stepsImage.jpegData(compressionQuality: 0.9)
    }
}
