//
//  Untitled.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/6/26.
//

import SwiftUI
import CoreBluetooth
import Combine

struct DeviceFamilyFinder: View {

    @StateObject var scanner = DeviceScanner(targetDeviceNames: ["Nano33", "SmartSole Right"])
    @State var selectedDeviceIDs = Set<UUID>()
    
    var selectedDevices: [Device] {
        scanner.foundDevices.filter { selectedDeviceIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            
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
                        Spacer()
                        Text(device.id.uuidString.prefix(4))
                            .font(.footnote)
                            .fontWeight(.ultraLight)
                    }
                    .contentShape(Rectangle())
                }
                .toolbar {
                    EditButton()
                }
                NavigationLink(destination: SessionSettings(selectedDevices: selectedDevices)) {
                    Text("Continue")
                        .foregroundStyle(.blue.gradient)
                        .font(.title)
                        .fontWeight(.thin)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 35)
                .padding(.vertical, 20)
                .buttonStyle(.glass)
                .buttonBorderShape(.roundedRectangle)
            }
        }
    }
}

#Preview {
    AllDeviceScannerHomepage()
}
