//
//  Theme.swift
//  Recipes
//
//  Created by Tony Short on 07/03/2023.
//

import SwiftUI

enum Colours {
    static let backgroundPrimary = Color("backgroundPrimary")
    static let backgroundSecondary = Color("backgroundSecondary")
    static let foregroundPrimary = Color("foregroundPrimary")
    static let foregroundSecondary = Color("foregroundSecondary")
}

extension Font {
    static var brand = Font.custom("Avenir Next",
                                   size: UIFont.preferredFont(forTextStyle: .body).pointSize)
}

struct ButtonText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .bold()
            .frame(maxWidth: .infinity)
    }
}
