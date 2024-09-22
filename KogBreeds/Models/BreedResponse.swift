// Copyright © 2024 Josh Adams. All rights reserved.

struct BreedResponse: Decodable {
    let message: [String: [String]]
    let status: String
}
