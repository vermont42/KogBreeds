// Copyright © 2024 Josh Adams. All rights reserved.

import UIKit

enum Loader {
  static func loadBreeds() async throws -> [Breed] {
    guard let breedsURL = URL(string: "https://dog.ceo/api/breeds/list/all") else {
      fatalError("Could not initialize breedsURL.")
    }
    let (jsonData, _) = try await URLSession.shared.data(from: breedsURL)
    let breedResponse = try JSONDecoder().decode(BreedResponse.self, from: jsonData)
    var breeds: [Breed] = []
    for (breed, subbreeds) in breedResponse.message {
      breeds.append(Breed(name: breed, subbreedCount: subbreeds.count, imageURLs: []))
    }

    var imageURLs: [String: [URL]] = [:]

    imageURLs = await withTaskGroup(of: (String, [URL]).self, returning: [String: [URL]].self) { taskGroup in
      for breed in breeds {
        taskGroup.addTask {
          let urls = await Loader.loadImageURLs(breed: breed.name)
          return (breed.name, urls)
        }
      }

      var urlResults: [String: [URL]] = [:]
      for await result in taskGroup {
        urlResults[result.0] = result.1
      }
      return urlResults
    }

    for breed in breeds {
      breed.imageURLs = imageURLs[breed.name] ?? []
      for url in breed.imageURLs {
        print(url)
      }
    }

    return breeds
  }

  static func loadImageURLs(breed: String) async -> [URL] {
    guard let imagesURL = URL(string: "https://dog.ceo/api/breed/\(breed)/images") else {
      fatalError("Could not initialize imagesURL.")
    }
    do {
      let (jsonData, _) = try await URLSession.shared.data(from: imagesURL)
      let imagesURLsResponse = try JSONDecoder().decode(ImagesURLsResponse.self, from: jsonData)
      if imagesURLsResponse.status != "success" {
        return []
      }
      var urls: [URL] = []
      for urlString in imagesURLsResponse.message {
        if let url = URL(string: urlString) {
          urls.append(url)
        }
      }
      return urls
    } catch {
      return []
    }
  }
}
