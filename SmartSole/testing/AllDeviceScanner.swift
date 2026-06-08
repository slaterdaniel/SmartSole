//
//  Untitled.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/6/26.
//

import SwiftUI
import CoreBluetooth
import Combine

class DeviceScanner:
        NSObject,
        CBCentralManagerDelegate,
        ObservableObject,
        CBPeripheralDelegate {
    
    @Published var state: CBManagerState = .unknown
    @Published var isScanning: Bool = false
    @Published var foundDevices: [Device] = []
    @Published var connectedDevice: Device? = nil
    
    private var manager: CBCentralManager!
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is ready to use")
            // You can safely start your scan here
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unsupported:
            print("Bluetooth is not supported on this device")
        default:
            break
        }
    }
    
    func centralManager(_ manager: CBCentralManager, didDiscover foundperipheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "No Name"
        if !foundDevices.contains(where: { $0.name == deviceName }) {
            print("DEVICE FOUND")
            print("Name:", deviceName)
            print("UUID:", foundperipheral.identifier)
            print()
            foundDevices.append(
                Device(
                    name: deviceName,
                    id: foundperipheral.identifier,
                    peripheral: foundperipheral
                )
            )
        }
    }
    
    func centralManager(_ manager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let device = foundDevices.first(where: { $0.id == peripheral.identifier }) {
            connectedDevice = device
            print("Device Connected")
            device.peripheral.discoverServices(nil)
        } else {
            print("Device could not be connected")
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: (any Error)?
    ) {
        guard let services = peripheral.services else {
            print("No Services")
            return
        }
        
        for service in services {
            print("Service Found:", service, service.uuid)
            print()
        }
    }
    
    func startScan() {
        foundDevices.removeAll()
        connectedDevice = nil
        isScanning = true
        manager.scanForPeripherals(withServices: nil)
    }
    
    func stopScan() {
        isScanning = false
        manager.stopScan()
    }
    
    func connectDevice(_ device: Device) {
        manager.connect(device.peripheral)
    }
}

struct Device: Identifiable {
    let name: String
    let id: UUID
    let peripheral: CBPeripheral
}

struct AllDeviceScannerHomepage: View {

    @StateObject private var scanner = DeviceScanner()
    
    var body: some View {
        VStack {
            Text("BLE Devices")
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
            List(scanner.foundDevices) { device in
                Button(action: {
                    print("DEVICE PRESSED: \(device.name) - \(device.id)")
                    scanner.connectDevice(device)
                }) {
                    HStack {
                        Text(device.name)
                        Spacer()
                        Text(device.id.uuidString.prefix(4))
                            .font(.footnote)
                            .fontWeight(.ultraLight)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.glass)
            }
            Button("other test button") {
                print("test button")
            }
        }
    }
}

#Preview {
    AllDeviceScannerHomepage()
}
