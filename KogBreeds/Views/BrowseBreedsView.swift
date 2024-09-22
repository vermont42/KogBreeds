// Copyright © 2024 Josh Adams. All rights reserved.

import SwiftUI

struct BrowseBreedsView: View {
  let viewModel = BrowseBreedsViewModel()
  @State private var images: [String: UIImage] = [:]
  private let photoHeightWidth: CGFloat = 150
  private let imageLoader = ImageLoader()

  var body: some View {
    NavigationStack {
      VStack {
        switch viewModel.state {
        case .loading:
          ProgressView()
        case .error:
          Text("ERROR")
        case .loaded(breeds: let breeds):
          list(of: breeds)
        }
      }
      .navigationTitle("Dog Breeds")
    }
    .task {
      await viewModel.loadBreeds()
    }
  }

  private func list(of breeds: [Breed]) -> some View {
    List(breeds) { breed in
      NavigationLink {
        BreedDetailsView(breed: breed, imageLoader: imageLoader)
      } label: {
        HStack {
          VStack(alignment: .leading) {
            Text(breed.name)
            Text("Subbreeds: \(breed.subbreedCount)")
          }

          Spacer()

          Group {
            if let image = images[breed.name] {
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
            guard !breed.imageURLs.isEmpty else {
              return
            }
            let url = breed.imageURLs[0]
            if let cachedImage = breed.images["\(url)"] {
              images[breed.name] = cachedImage
            } else {
              let freshImage = await imageLoader.load(url: url)
              images[breed.name] = freshImage
              breed.images["\(url)"] = freshImage
            }
          }
        }
        .padding()
      }
    }
  }
}

#Preview {
  BrowseBreedsView()
}
