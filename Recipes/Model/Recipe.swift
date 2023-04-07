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
                     plateImage: UIImage?,
                     stepsImage: UIImage?) {
        self.init(context: context)
        self.dateAdded = Date()
        self.name = name
        self.plateImageData = plateImage?.jpegData(compressionQuality: Self.compressionQuality)
        self.stepsImageData = stepsImage?.jpegData(compressionQuality: Self.compressionQuality)
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
}
