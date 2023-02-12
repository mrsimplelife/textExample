//
//  TestDownloader.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import Foundation

class TestDownloader: HTTPDataDownloader {
    func httpData(from _: URL) async throws -> Data {
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000 ... 500_000_000))
        return testQuakesData
    }
}
