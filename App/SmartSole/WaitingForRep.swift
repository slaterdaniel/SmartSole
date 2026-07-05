//
//  DataDisplayPage.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/8/26.
//

import SwiftUI
import CoreBluetooth
import RealityKit

extension Collection {
    /// Safely accesses an element at a given index. Returns nil if out of bounds.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

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
            HStack {
                RealityView { content in
                    do {
                        let shoe = try await Entity(named: "DistanceShoeRight")
                        var t = shoe.transform
                        t.scale = [0.4, 0.4, 0.4]
                        shoe.transform = t
                        shoe.position = [0, 0, 0]
                        content.add(shoe)
                    }
                    catch {
                        print("Failed to load SHOE model:", error)
                    }
                } update: { content in
                    if let shoe = content.entities.first {
                        shoe.orientation = bleManager.currentData.angles
                    }
                }
                .frame(width: 150)
    //            Spacer()
    //                .frame(height: 200) // 275
                Section {
                    VStack {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 10] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 10] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 11] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 11] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 8] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 8] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 9] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 9] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 6] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 6] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 7] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 7] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 4] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 4] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 5] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 5] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 2] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 2] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 3] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 3] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 0] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 0] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 45, height: 45)
                                .opacity(Double((bleManager.currentData.forces[safe: 1] ?? 0) ?? 0) / 35)
//                                .overlay(
//                                    Text(String((bleManager.currentData.forces[safe: 1] ?? 0) ?? 0))
//                                )
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
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
