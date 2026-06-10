//
//  Untitled.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/6/26.
//

import SwiftUI
import CoreBluetooth

struct DeviceFamilyFinder: View {

    @State private var path = NavigationPath()
    
    @StateObject var scanner = DeviceScanner(targetDeviceNames: ["Nano33", "SmartSole Right"])
    @State var selectedDeviceIDs = Set<UUID>()
    
    
    var selectedDevices: [Device] { scanner.foundDevices.filter { selectedDeviceIDs.contains($0.id) } }
    
    var body: some View {
        
        NavigationStack (path: $path) {
            VStack {
                Text("SmartSole BLE Devices")
                    .fontWeight(.thin)
                    .font(.largeTitle)
                Button(action: {
                    scanner.startScan()
                }) {
                    Text("Start Scan")
                        .fontWeight(.thin)
                        .font(.title2)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke()
                        )
                }
                List(scanner.foundDevices, id: \.id, selection: $selectedDeviceIDs) { device in
                    HStack {
                        Text(device.name)
                            .foregroundStyle(.blue.gradient)
                        Spacer()
                        Text(device.id.uuidString.prefix(4))
                            .font(.footnote)
                            .fontWeight(.ultraLight)
                    }
                    .padding()
                    .contentShape(Rectangle())
                }
                .toolbar {
                    EditButton()
                }
                NavigationLink(destination: SessionSettings(selectedDevices: selectedDevices)) {
                    Text("Continue")
                        .padding(.horizontal, 55)
                        .padding(.vertical, 15)
                        .foregroundStyle(.blue.gradient)
                        .font(.title)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.glass)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        scanner.stopScan()

                        for device in selectedDevices {
                            scanner.connectDevice(device)
                        }
                    }
                )
            }
        }
    }
}
