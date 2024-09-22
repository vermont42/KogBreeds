// Copyright © 2024 Josh Adams. All rights reserved.

import Observation

@Observable
class BrowseBreedsViewModel {
  enum State: Equatable {
    case loading
    case loaded(breeds: [Breed])
    case error
  }

  var state = State.loading

  func loadBreeds(mockedState: State? = nil) async {
    if let mockedState {
      self.state = mockedState
    } else {
      state = .loading
      do {
        let breeds = try await Loader.loadBreeds()
        state = .loaded(breeds: breeds)
      } catch {
        state = .error
      }
    }

    switch state {
    case .loading:
      break
    case .loaded:
      print("Perhaps play a happy sound.")
    case .error:
      print("Perhaps play a sad sound.")
    }
  }
}
