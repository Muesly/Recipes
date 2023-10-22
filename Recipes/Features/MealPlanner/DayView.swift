//
//  DayView.swift
//  Recipes
//
//  Created by Tony Short on 16/04/2023.
//

import Foundation
import SwiftUI

struct DayView: View {
    @ObservedObject var viewModel: DayViewModel
    @State var notes: String = ""
    @FocusState private var notesIsFocused: Bool
    @State private var recipeImage = Image(uiImage: UIImage())
    @State private var recipeDropItem: RecipeDropItem = .none
    @State private var placeholder: String = "Notes"

    var body: some View {
        HStack {
            Text(viewModel.meal.day!)
                .bold()
                .frame(width: 50, height: 40, alignment: .center)
                .padding(5)
            VStack(spacing: 0) {
                Button {
                    viewModel.togglePerson1Present()
                } label: { Image(uiImage: UIImage(named: viewModel.person1IconForMeal)!)
                        .resizable()
                        .frame(width: 25, height:25)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                }
                Button {
                    viewModel.togglePerson2Present()
                } label: { Image(uiImage: UIImage(named: viewModel.person2IconForMeal)!)
                        .resizable()
                        .frame(width: 25, height:25)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                }
            }
            Image(uiImage: viewModel.mealForName(recipeDropItem.text)?.recipe?.plateImage ??
                  UIImage(named: "ThumbnailPlaceholder")!)
            .resizable()
            .frame(width: 50, height: 50)
            .cornerRadius(5)
            .dropDestination(for: RecipeDropItem.self) { items, location in
                recipeDropItem = items.first!
                viewModel.moveRecipeToMeal(recipeDropItem.text)
                notes += recipeDropItem.text ?? ""
                return true
            }
            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(2)
                .focused($notesIsFocused)
        }
        .background(Colours.backgroundSecondary)
        .border(.gray, width: 1)
    }
}

enum RecipeDropItem: Codable, Transferable {
    case none
    case text(String)

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { RecipeDropItem.text($0) }
    }

    var text: String? {
        switch self {
        case .text(let str): return str
        default: return nil
        }
    }
}
