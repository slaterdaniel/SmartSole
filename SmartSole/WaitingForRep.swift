//
//  DataDisplayPage.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/8/26.
//

import SwiftUI
import CoreBluetooth
import RealityKit

struct WaitingForRep: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var bleManager: BLEManager
    
    @State var startingOrientation: simd_quatf = simd_quatf()
    
    func printTree(_ entity: Entity, depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)\(entity.name)")

        for child in entity.children {
            printTree(child, depth: depth + 1)
        }
    }
    
    var body: some View {
        VStack {
            RealityView { content in
                do {
                    let shoe = try await Entity(named: "DistanceShoe")
                    var t = shoe.transform
//                    let radians: Float = 45 * .pi / 180.0
//                    t.rotation = simd_quatf(angle: radians, axis: [1, 0, 0])
                    t.scale = [0.4, 0.4, 0.4]
                    shoe.transform = t
                    shoe.position = [0, 0, 0]
                    startingOrientation = shoe.orientation
                    printTree(shoe)
                    content.add(shoe)
                } catch {
                    print("Failed to load SHOE model:", error)
                }
            } update: { content in
                if let shoe = content.entities.first {
                    shoe.orientation = bleManager.currentData.angles * startingOrientation
                }
            }
            Section {
                HStack {
                    Text("Accels:")
                    Text(bleManager.currentData.accels)
                }
                HStack {
                    Text("Angles:")
//                    Text(bleManager.currentData.angles)
                }
                HStack {
                    Text("Angle Accels:")
                    Text(bleManager.currentData.angleAccels)
                }
            }
//            Spacer()
//                .frame(height: 200) // 275
            Text("Waiting for Rep to Start")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue.gradient)
            Spacer()
                .frame(height: 50)
            VStack (spacing: 20) {
                HStack {
                    Text("Leading Foot")
                    Text("Down")
                        .underline()
                }
                HStack {
                    Text("Trailing Foot on")
                    Text("Toe")
                        .underline()
                }
                Spacer()
                    .frame(height: 20)
                Text("Step")
                Image(systemName: "arrow.down")
                Text("Hang")
                Image(systemName: "arrow.down")
                Text("Takeoff")

            }
            .fontWeight(.ultraLight)
            .frame(maxWidth: 300)
            Spacer()
            Button("Cancel Analysis") {
                dismiss()
            }
            .fontWeight(.ultraLight)
            .font(.custom("", size: 12))
            .padding(.horizontal, 35)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
            )
            .foregroundStyle(.red.opacity(0.75).gradient)
            .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden()
    }
}
