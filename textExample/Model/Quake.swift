//
//  Quake.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import Foundation

struct Quake {
    let magnitude: Double
    let place: String
    let time: Date
    let code: String
    let detail: URL
    var location: QuakeLocation?
}

// MARK: Identifiable

extension Quake: Identifiable {
    var id: String { self.code }
}

// MARK: Decodable

extension Quake: Decodable {
    private enum CodingKeys: String, CodingKey {
        case magnitude = "mag"
        case place
        case time
        case code
        case detail
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawMagnitude = try? values.decode(Double.self, forKey: .magnitude)
        let rawPlace = try? values.decode(String.self, forKey: .place)
        let rawTime = try? values.decode(Date.self, forKey: .time)
        let rawCode = try? values.decode(String.self, forKey: .code)
        let rawDetail = try? values.decode(URL.self, forKey: .detail)
        guard let magnitude = rawMagnitude,
              let place = rawPlace,
              let time = rawTime,
              let code = rawCode,
              let detail = rawDetail else
        {
            throw QuakeError.missingData
        }
        self.magnitude = magnitude
        self.place = place
        self.time = time
        self.code = code
        self.detail = detail
    }
}
