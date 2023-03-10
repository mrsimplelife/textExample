//
//  textExampleApp.swift
//  textExample
//
//  Created by youme on 2023/02/12.
//

import SwiftUI

@main
struct textExampleApp: App {
    @StateObject var quakesProvider = QuakesProvider()

    var body: some Scene {
        WindowGroup {
            Quakes()
                .environmentObject(quakesProvider)
        }
    }
}
