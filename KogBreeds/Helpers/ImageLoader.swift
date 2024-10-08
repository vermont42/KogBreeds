// Copyright © 2024 Josh Adams. All rights reserved.

import UIKit

actor ImageLoader {
  private var loaderStatuses: [URL: LoaderStatus] = [:]

  private enum LoaderStatus {
    case inProgress(Task<UIImage, Error>)
    case fetched(UIImage)
  }

  func load(url: URL) async -> UIImage {
    let errorImage = UIImage(systemName: "cloud.drizzle") ?? UIImage()

    if let status = loaderStatuses[url] {
      switch status {
      case .fetched(let image):
        return image
      case .inProgress(let task):
        return (try? await task.value) ?? errorImage
      }
    }

    let task: Task<UIImage, Error> = Task {
      let image: UIImage

      do {
        let (imageData, _) = try await URLSession.shared.data(from: url)
        let imageFromNetwork = UIImage(data: imageData)
        image = imageFromNetwork ?? errorImage
      } catch {
        image = errorImage
      }

      return image
    }

    loaderStatuses[url] = .inProgress(task)

    do {
      let image = try await task.value
      loaderStatuses[url] = .fetched(image)
      return image
    } catch {
      loaderStatuses[url] = .fetched(errorImage)
      return errorImage
    }
  }
}
