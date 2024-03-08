//
//  TestingApp.swift
//  Testing
//
//  Created by Sandeep K on 3/8/24.
//

import SwiftUI

@main
struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
