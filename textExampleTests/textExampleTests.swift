//
//  textExampleTests.swift
//  textExampleTests
//
//  Created by youme on 2023/02/12.
//

@testable import textExample
import XCTest

final class textExampleTests: XCTestCase {

    func testGeoJSONDecoderDecodesQuake() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let quake = try decoder.decode(Quake.self, from: testFeature_nc73649170)

        XCTAssertEqual(quake.code, "73649170")

        let expectedSeconds = TimeInterval(1_636_129_710_550) / 1_000
        let decodedSeconds = quake.time.timeIntervalSince1970

        XCTAssertEqual(expectedSeconds, decodedSeconds, accuracy: 0.00001)
    }

    func testGeoJSONDecoderDecodesGeoJSON() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decoded = try decoder.decode(GeoJSON.self, from: testQuakesData)

        XCTAssertEqual(decoded.quakes.count, 6)
        XCTAssertEqual(decoded.quakes[0].code, "73649170")

        let expectedSeconds = TimeInterval(1_636_129_710_550) / 1_000
        let decodedSeconds = decoded.quakes[0].time.timeIntervalSince1970
        XCTAssertEqual(expectedSeconds, decodedSeconds, accuracy: 0.00001)
    }

    func testQuakeDetailsDecoder() throws {
        let decoded = try JSONDecoder().decode(QuakeLocation.self, from: testDetail_hv72783692)
        XCTAssertEqual(decoded.latitude, 19.2189998626709, accuracy: 0.00000000001)
    }

    func testClientDoesFetchEarthquakeData() async throws {
        let downloader = TestDownloader()
        let client = QuakeClient(downloader: downloader)
        let quakes = try await client.quakes

        XCTAssertEqual(quakes.count, 6)
    }

}
