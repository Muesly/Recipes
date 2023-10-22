//
//  MealPlannerViewModel.swift
//  Recipes
//
//  Created by Tony Short on 14/04/2023.
//

import CoreData
import Foundation

class MealPlannerViewModel: ObservableObject {
    let context: NSManagedObjectContext
    @Published var recipes = [Recipe]()

    init(context: NSManagedObjectContext) {
        self.context = context
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

    var meals: [Meal] {
        return mealPlan.meals!.allObjects as! [Meal]
    }

    func updateRecipes() {
        recipes = (mealPlan.recipes?.allObjects as? [Recipe]) ?? []
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

    func moveRecipeToMeal(_ name: String?, meal: Meal) {
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

    func person1IconForMeal(_ meal: Meal) -> String {
        return meal.person1Present ? "KarenIn" : "KarenOut"
    }

    func person2IconForMeal(_ meal: Meal) -> String {
        return meal.person2Present ? "TonyIn" : "TonyOut"
    }

    func togglePerson1Present(_ meal: Meal) {
        meal.person1Present = !meal.person1Present
    }

    func togglePerson2Present(_ meal: Meal) {
        meal.person2Present = !meal.person2Present
    }
}
