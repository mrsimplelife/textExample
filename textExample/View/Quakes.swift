//
//  Quakes.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import SwiftUI

let staticData: [Quake] = [
    Quake(
        magnitude: 0.8,
        place: "Shakey Acres",
        time: Date(timeIntervalSinceNow: -1_000),
        code: "nc73649170",
        detail: URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/nc73649170.geojson")!
    ),
    Quake(
        magnitude: 2.2,
        place: "Rumble Alley",
        time: Date(timeIntervalSinceNow: -5_000),
        code: "hv72783692",
        detail: URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/hv72783692")!
    )
]

struct Quakes: View {
    @AppStorage("lastUpdated") var lastUpdated = Date.distantFuture.timeIntervalSince1970
    @EnvironmentObject var provider: QuakesProvider
    @State var editMode: EditMode = .inactive
    @State var selectMode: SelectMode = .inactive
    @State var isLoading = false
    @State var selection: Set<String> = []
    @State private var error: QuakeError?
    @State private var hasError = false

    var body: some View {
        NavigationView {
            List(selection: $selection) {
                ForEach(self.provider.quakes) { quake in
                    QuakeRow(quake: quake)
                }
                .onDelete(perform: deleteQuakes)
            }
            .listStyle(.inset)
            .navigationTitle(title)
            .toolbar(content: toolbarContent)
            .environment(\.editMode, $editMode)
            .refreshable {
                await fetchQuakes()
            }
            .alert(isPresented: $hasError, error: error) {}
        }
        .task {
            await fetchQuakes()
        }
    }
}

extension Quakes {
    var title: String {
        if self.selectMode.isActive || self.selection.isEmpty {
            return "Earthquakes"
        } else {
            return "\(self.selection.count) Selected"
        }
    }

    func deleteQuakes(at offsets: IndexSet) {
        self.provider.deleteQuakes(atOffsets: offsets)
    }

    func deleteQuakes(for codes: Set<String>) {
        var offsetsToDelete: IndexSet = []
        for (index, element) in self.provider.quakes.enumerated() {
            if codes.contains(element.code) {
                offsetsToDelete.insert(index)
            }
        }
        self.deleteQuakes(at: offsetsToDelete)
        self.selection.removeAll()
    }

    func fetchQuakes() async {
        self.isLoading = true
        do {
            try await self.provider.fetchQuakes()
            self.lastUpdated = Date().timeIntervalSince1970
        } catch {
            self.error = error as? QuakeError ?? .unexpectedError(error: error)
            self.hasError = true
        }
        self.isLoading = false
    }
}

struct Quakes_Previews: PreviewProvider {
    static var previews: some View {
        Quakes()
            .environmentObject(QuakesProvider(client: QuakeClient(downloader: TestDownloader())))
    }
}
