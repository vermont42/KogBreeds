// Copyright © 2024 Josh Adams. All rights reserved.

import UIKit

class Breed: Identifiable, Equatable {
  let id: String
  let name: String
  let subbreedCount: Int
  var imageURLs: [URL]
  var images: [String: UIImage]

  init(name: String, subbreedCount: Int, imageURLs: [URL]) {
    self.name = name
    self.subbreedCount = subbreedCount
    self.imageURLs = imageURLs
    self.id = name
    images = [:]
  }

  static func == (lhs: Breed, rhs: Breed) -> Bool {
    lhs.name == rhs.name
  }

  static var mock: Breed {
    guard let imageURL = URL(string: "https://images.dog.ceo/breeds/spitz-japanese/tofu.jpg") else {
      fatalError()
    }
    return Breed(name: "Spitz", subbreedCount: 2, imageURLs: [imageURL])
  }
}
