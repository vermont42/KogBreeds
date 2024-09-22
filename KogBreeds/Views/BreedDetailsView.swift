// Copyright © 2024 Josh Adams. All rights reserved.

import SwiftUI

struct BreedDetailsView: View {
  let breed: Breed
  let imageLoader: ImageLoader
  @State private var image: UIImage?
  private let photoHeightWidth: CGFloat = 250

  var body: some View {
    VStack {
      Group {
        if let image  {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
        } else {
          ProgressView()
        }
      }
      .frame(width: photoHeightWidth, height: photoHeightWidth)
      .task {
        await getAndSetImage(index: 0)
      }

      Text(breed.name)
      Text("Subbreed Count: \(breed.subbreedCount)")

      Button("Load Another Photo") {
        Task {
          await getAndSetImage(index: Int.random(in: 0 ..< breed.imageURLs.count))
        }
      }
    }
    .navigationTitle(breed.name)
  }

  func getAndSetImage(index: Int) async {
    guard !breed.imageURLs.isEmpty else {
      return
    }
    let url = breed.imageURLs[index]
    print(url)
    if let cachedImage = breed.images["\(url)"] {
      image = cachedImage
    } else {
      let freshImage = await imageLoader.load(url: url)
      image = freshImage
      breed.images["\(url)"] = freshImage
    }
  }
}

#Preview {
  BreedDetailsView(breed: Breed.mock, imageLoader: ImageLoader())
}
