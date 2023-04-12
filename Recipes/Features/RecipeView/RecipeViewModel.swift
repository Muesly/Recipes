//
//  RecipeViewModel.swift
//  Recipes
//
//  Created by Tony Short on 06/03/2023.
//

import AVFoundation
import CoreData
import Foundation
import SwiftUI

class RecipeViewModel {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    static func recipeTitle(for name: String) -> String {
        return name.isEmpty ? "New Recipe" : name
    }

    func addOrEditRecipe(recipe: Recipe?,
                         name: String,
                         plateImage: UIImage?,
                         stepsImage: UIImage?,
                         calories: Int32,
                         categories: NSSet?,
                         book: Book?,
                         page: Int32,
                         rating: Int16,
                         suggestions: String) {

        let recipeToEdit = recipe ?? Recipe(context: viewContext, name: name, plateImage: plateImage, stepsImage: stepsImage)
        recipeToEdit.name = name
        recipeToEdit.plateImageData = plateImage?.jpegData(compressionQuality: 0.9)
        recipeToEdit.stepsImageData = stepsImage?.jpegData(compressionQuality: 0.9)
        recipeToEdit.calories = calories
        recipeToEdit.categories = categories
        recipeToEdit.book = book
        recipeToEdit.page = page
        recipeToEdit.rating = rating
        recipeToEdit.suggestions = suggestions

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

class CameraManager : ObservableObject {
    @Published var permissionGranted = false

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            DispatchQueue.main.async {
                self.permissionGranted = accessGranted
            }
        })
    }
}

