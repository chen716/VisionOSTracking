//
//  ImmersiveView.swift
//  Testing
//
//  Created by Sandeep K on 3/8/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit
import Network



struct ImmersiveView: View{
    @ObservedObject var gestureModel: HeartGestureModel
    @State var session = ARKitSession()
    @State private var handsCenterTransform: SIMD3<Float>?
    @State private var trackedAnchorTransform:SIMD3<Float>?
    @State private var offsetValue: SIMD3<Float> = .zero
    let udpSender = UDPSender()
//    @State var immersionState: ImmersionStyle = .mixed
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
//    @MainActor var entityMap: [UUID: Entity] = [:]
    let imageInfo = ImageTrackingProvider(
        referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "AR Resources")
    )
    
    var body: some View{
        RealityView {content in
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle){
                content.add(scene)
            }
            let textEntity = ModelEntity(mesh: .generateText("Offset: \(offsetValue.x), \(offsetValue.y), \(offsetValue.z)", extrusionDepth: 0.01, font: .systemFont(ofSize: 10), containerFrame: .zero, alignment: .left, lineBreakMode: .byTruncatingTail))
                        
                        textEntity.scale = SIMD3<Float>(5, 5, 5)
                        textEntity.position = SIMD3<Float>(0, 0.3, 0.5)
                        textEntity.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))
                        
                        content.add(textEntity)
        }update: { updateContent in
            let handsCenterTransform = gestureModel.computeLeftFinger()
           
            diff  = handsCenterTransform - tf1
            
            let x = diff.x
            let y = diff.y
            let z = diff.z
            let msg = "here:\(x),\(y),\(z)"

            udpSender.send(message: msg, to: "192.168.86.33", port: 8080)
            
            
        }
        .task{
            do{
                print("requesting permissions")
                let _permissions = await session.requestAuthorization(for:[. worldSensing])
                print("received permissions")
                if ImageTrackingProvider.isSupported {
                Task {
                    try await session.run([imageInfo])
                    for await update in imageInfo.anchorUpdates {
                        let trackedAnchorTransform = update.anchor.originFromAnchorTransform.columns.3.xyz
                        tf1 = trackedAnchorTransform
                    }
                }
            }
            }
        }
        
        .task {
            await gestureModel.start()
        }
        .task {
            await gestureModel.publishHandTrackingUpdates()
        }
        .task {
            await gestureModel.monitorSessionEvents()
        }
      
        VStack {
            Spacer()
            Text("Offset: \(offsetValue.x), \(offsetValue.y), \(offsetValue.z)")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding()
        }
    }
        
    
}
var windowSize = 24
var tf1: SIMD3<Float> = .init(repeating: 0)
var diff: SIMD3<Float> = .init(repeating: 0)

class UDPSender {
    var connection: NWConnection?

    init() {
        // Initialization code if needed
    }

    func send(message: String, to ipAddress: String, port: UInt16) {
        if connection == nil {
                    let host = NWEndpoint.Host(ipAddress)
                    let port = NWEndpoint.Port(rawValue: port)!
                    connection = NWConnection(host: host, port: port, using: .udp)
                    connection?.stateUpdateHandler = { state in
                        // Handle the connection state update
                    }
                    connection?.start(queue: .global())
                }
        self.sendData(message)
    }

    private func sendData(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }

        connection?.send(content: data, completion: .contentProcessed({ sendError in
            if let error = sendError {
                print("Send error: \(error)")
            }
        }))
    }

    func stop() {
        connection?.cancel()
    }
}
