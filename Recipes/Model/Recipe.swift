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
    static var compressionQuality = 0.9
    convenience init(context: NSManagedObjectContext,
                     name: String,
                     plateImage: UIImage? = nil,
                     stepsImage: UIImage? = nil,
                     categories: NSSet? = nil,
                     book: Book? = nil,
                     page: Int32 = 0,
                     rating: Int16 = 4,
                     suggestions: String = "") {
        self.init(context: context)
        self.dateAdded = Date()
        self.name = name
        self.plateImageData = plateImage?.jpegData(compressionQuality: Self.compressionQuality)
        self.stepsImageData = stepsImage?.jpegData(compressionQuality: Self.compressionQuality)
        self.categories = categories
        self.book = book
        self.page = page
        self.rating = rating
        self.suggestions = suggestions
    }

    var plateImage: UIImage? {
        guard let data = plateImageData else {
            return nil
        }
        return UIImage(data: data)
    }

    var stepsImage: UIImage? {
        guard let data = stepsImageData else {
            return nil
        }
        return UIImage(data: data)
    }

    var isGenerated: Bool {
        return (ingredients != nil)  // Generated recipes have ingredients field defined
    }
}
