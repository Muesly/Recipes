//
//  MealPlannerView.swift
//  Recipes
//
//  Created by Tony Short on 12/04/2023.
//

import CoreTransferable
import SwiftUI

struct MealPlannerView: View {
    @ObservedObject var viewModel: MealPlannerViewModel

    init(viewModel: MealPlannerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(viewModel.recipes) { recipe in
                            HStack {
                                Image(uiImage: recipe.plateImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                                    .draggable(recipe.name ?? "N/A")
                            }
                        }
                    }
                }
                .frame(height: 50)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                VStack(alignment: .leading) {
                    ForEach(viewModel.meals) { meal in
                        DayView(viewModel: DayViewModel(context: viewModel.context,
                                                        meal: meal))
                    }
                }
                .padding()
                .navigationTitle("Meal Planner")
                .font(.brand)
            }
        }
        .onAppear {
            viewModel.updateRecipes()
        }
    }
}
