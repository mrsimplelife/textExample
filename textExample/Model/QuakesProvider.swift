//
//  QuakesProvider.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import Foundation

@MainActor
class QuakesProvider: ObservableObject {
    @Published var quakes: [Quake] = []

    let client: QuakeClient

    init(client: QuakeClient = QuakeClient()) {
        self.client = client
    }

    func fetchQuakes() async throws {
        let latestQuakes = try await client.quakes
        self.quakes = latestQuakes
    }

    func deleteQuakes(atOffsets offsets: IndexSet) {
        self.quakes.remove(atOffsets: offsets)
    }
}
