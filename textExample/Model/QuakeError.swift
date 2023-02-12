//
//  QuakeError.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import Foundation

enum QuakeError: Error {
    case missingData
}

// MARK: LocalizedError

extension QuakeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingData: return NSLocalizedString(
                "Found and will discard a quake missing a valid code, magnitude, place, or time.",
                comment: ""
            )
        }
    }
}
