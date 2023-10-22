//
//  DayViewModel.swift
//  Recipes
//
//  Created by Tony Short on 16/04/2023.
//

import CoreData
import Foundation

class DayViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var meal: Meal

    init(context: NSManagedObjectContext,
         meal: Meal) {
        self.context = context
        self.meal = meal
    }

    var mealPlan: MealPlan {
        let request = MealPlan.fetchRequest()
        var mealPlan = try? context.fetch(request).first
        if mealPlan == nil {
            mealPlan = MealPlan(viewContext: context)
            do {
                try context.save()
            } catch {
                print("Failed to create meal plan")
            }
        }
        return mealPlan!
    }

    private func recipeForName(_ name: String?) -> Recipe? {
        guard let name else {
            return nil
        }
        return (mealPlan.recipes?.allObjects as? [Recipe])?.first(where: { recipe in
            return recipe.name == name
        })
    }

    func mealForName(_ name: String?) -> Meal? {
        guard let name else {
            return nil
        }
        return (mealPlan.meals?.allObjects as? [Meal])?.first(where: { meal in
            return meal.recipe?.name == name
        })
    }

    func moveRecipeToMeal(_ name: String?) {
        guard let recipe = recipeForName(name) else {
            return
        }
        mealPlan.removeFromRecipes(recipe)
        meal.recipe = recipe

        do {
            try context.save()
        } catch {
            print("Failed to move recipe to meal")
        }
    }

    var person1IconForMeal: String {
        meal.person1Present ? "KarenIn" : "KarenOut"
    }

    var person2IconForMeal: String {
        meal.person2Present ? "TonyIn" : "TonyOut"
    }

    func togglePerson1Present() {
        meal.person1Present = !meal.person1Present
    }

    func togglePerson2Present() {
        meal.person2Present = !meal.person2Present
    }
}
