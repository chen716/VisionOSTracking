//
//  TestingApp.swift
//  Testing
//
//  Created by Sandeep K on 3/8/24.
//

import SwiftUI

@main
struct TestingApp: App {
    @State private var immersionState: ImmersionStyle = .mixed
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(gestureModel: HeartGestureModelContainer.heartGestureModel)
        }.immersionStyle(selection: $immersionState , in: .mixed)
    }
}
@MainActor
enum HeartGestureModelContainer {
    private(set) static var heartGestureModel = HeartGestureModel()
    
}
