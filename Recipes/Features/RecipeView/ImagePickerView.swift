//
//  ImagePickerView.swift
//  Recipes
//
//  Created by Tony Short on 08/04/2023.
//

import SwiftUI

struct ImagePickerView: View {
    let title: String
    @Binding private var image: UIImage?
    @State private var actionSheetShown = false
    @State private var fullScreenImageShown = false
    @State private var takeAPhotoOption = false
    @State private var chooseFromLibraryOption = false

    init(title: String, image: Binding<UIImage?>) {
        self.title = title
        _image = image
    }

    var body: some View {
        HStack {
            Text(title).modifier(RecipeFormTitleText())
            Button {
                if image == nil {
                    actionSheetShown = true
                } else {
                    fullScreenImageShown = true
                }
            } label: {
                Image(uiImage: image ?? UIImage(named: "ThumbnailPlaceholder")!)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(10)
            }
            if image != nil {
                Button {
                    self.image = nil
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Select an option", isPresented: $actionSheetShown, titleVisibility: .hidden) {
            Button("Take a photo") {
                takeAPhotoOption = true
            }
            Button("Choose from library") {
                chooseFromLibraryOption = true
            }
        }
        .sheet(isPresented: $takeAPhotoOption) {
            ImagePicker(sourceType: .camera, selectedImage: self.$image)
        }
        .sheet(isPresented: $chooseFromLibraryOption) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
        .sheet(isPresented: $fullScreenImageShown) {
            PhotoView(image: self.image!)
        }
    }
}
