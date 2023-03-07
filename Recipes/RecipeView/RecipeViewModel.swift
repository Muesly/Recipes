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
    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func addRecipe(name: String,
                   plateImage: UIImage?,
                   stepsImage: UIImage?) {
        let _ = Recipe(context: viewContext, name: name, plateImage: plateImage, stepsImage: stepsImage)

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func editRecipe(recipe: Recipe,
                    name: String,
                    plateImage: UIImage?,
                    stepsImage: UIImage?) {
        recipe.name = name
        recipe.plateImage = plateImage?.jpegData(compressionQuality: 0.9)
        recipe.stepsImage = stepsImage?.jpegData(compressionQuality: 0.9)

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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

