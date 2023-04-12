//
//  MealPlannerView.swift
//  Recipes
//
//  Created by Tony Short on 12/04/2023.
//

import SwiftUI

struct MealPlannerView: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(uiImage: UIImage(named: "Tony")!).resizable()
                    Image(uiImage: UIImage(named: "Karen")!).resizable()
                    Image(uiImage: UIImage(named: "Tony")!).resizable()
                    Image(uiImage: UIImage(named: "Karen")!).resizable()
                    Image(uiImage: UIImage(named: "Tony")!).resizable()
                    Image(uiImage: UIImage(named: "Karen")!).resizable()
                    Image(uiImage: UIImage(named: "Tony")!).resizable()
                }
                .frame(height: 40)
                .padding()
                VStack(alignment: .leading) {
                    DayView(day: "Monday")
                    DayView(day: "Tuesday")
                    DayView(day: "Wednesday")
                    DayView(day: "Thursday")
                    DayView(day: "Friday")
                    DayView(day: "Saturday")
                    DayView(day: "Sunday")
                }
                .padding()
                .navigationTitle("Meal Planner")
                .font(.brand)
            }
        }
    }
}

struct DayView: View {
    let day: String
    @State var notes: String = ""
    @FocusState private var notesIsFocused: Bool

    var body: some View {
        HStack {
            Text(day)
                .frame(width: 100, height: 40, alignment: .center)
                .padding(5)
            VStack {
                Button {} label: { Image(uiImage: UIImage(named: "Karen")!)
                        .resizable()
                        .frame(width: 24, height:24)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                }
                Button {} label: { Image(uiImage: UIImage(named: "Tony")!)
                        .resizable()
                        .frame(width: 24, height:24)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                }
            }
            VStack(alignment: .leading) {
                Button {

                } label: {
                    Text("Pick recipe...")
                }
                .frame(height: 20)
                TextField("Notes", text: $notes)
                    .frame(height: 20)
                    .focused($notesIsFocused)
            }
        }
        .background(Colours.backgroundSecondary)
        .border(.gray, width: 1)
    }
}
