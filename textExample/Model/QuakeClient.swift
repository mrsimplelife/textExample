//
//  QuakeClient.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import Foundation

actor QuakeClient {
    private lazy var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970
        return aDecoder
    }()

    private let feedURL = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson")!
    private let quakeCache: NSCache<NSString, CacheEntryObject> = NSCache()

    private let downloader: any HTTPDataDownloader

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }

    var quakes: [Quake] {
        get async throws {
            let data = try await downloader.httpData(from: self.feedURL)
            let allQuakes = try decoder.decode(GeoJSON.self, from: data)
            var updatedQuakes = allQuakes.quakes
            if let olderThanOneHour = updatedQuakes.firstIndex(where: { $0.time.timeIntervalSinceNow > 3_000 }) {
                let indexRange = updatedQuakes.startIndex ..< olderThanOneHour
                try await withThrowingTaskGroup(of: (Int, QuakeLocation).self, body: { group in
                    for index in indexRange {
                        group.addTask {
                            let location = try await self.quakeLocation(from: allQuakes.quakes[index].detail)
                            return (index, location)
                        }
                    }
                    while let result = await group.nextResult() {
                        switch result {
                        case let .failure(error):
                            throw error
                        case .success(let (index, location)):
                            updatedQuakes[index].location = location
                        }
                    }
                })
            }
            return updatedQuakes
        }
    }

    func quakeLocation(from url: URL) async throws -> QuakeLocation {
        if let cached = quakeCache[url] {
            switch cached {
            case let .ready(location):
                return location
            case let .inProgress(task):
                return try await task.value
            }
        }
        let task = Task<QuakeLocation, Error> {
            let data = try await downloader.httpData(from: url)
            let location = try decoder.decode(QuakeLocation.self, from: data)
            return location
        }
        self.quakeCache[url] = .inProgress(task)
        do {
            let location = try await task.value
            self.quakeCache[url] = .ready(location)
            return location
        } catch {
            self.quakeCache[url] = nil
            throw error
        }
    }

}
