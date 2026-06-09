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
    private var targetDeviceNames: [String]? = nil

    
    init(targetDeviceNames: [String]?) {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
        self.targetDeviceNames = targetDeviceNames
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
    
//    PERIPHERAL DISCOVERY
    
    func centralManager(
        _ manager: CBCentralManager,
        didDiscover foundPeripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "No Name"
        
//        Remove this clause when done with testing
        if !foundDevices.contains(where: { $0.name == deviceName }) {
            print("DEVICE FOUND")
            print("Name:", deviceName)
            print("UUID:", foundPeripheral.identifier)
            print()
//       -------------
            if self.targetDeviceNames?.contains(where: { $0 == deviceName }) ?? true {
                foundDevices.append(
                    Device(
                        name: deviceName,
                        id: foundPeripheral.identifier,
                        peripheral: foundPeripheral
                    )
                )
            }
        }
    }
    
//    PERIPHERAL CONNECTION / DISCONNECTION
    
    func centralManager(
        _ manager: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        if let device = foundDevices.first(where: { $0.id == peripheral.identifier }) {
            connectedDevice = device
            print("Device Connected")
            device.peripheral.delegate = self
            device.peripheral.discoverServices(nil)
        } else {
            print("Device could not be connected")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        print("DEVICE DISCONNECTED")
    }
    
//    PERIPHERAL SERVICES
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: (any Error)?
    ) {
        
//    Testing --> to remove
        guard let services = peripheral.services else {
            print("No Services")
            return
        }
        for service in services {
            print("Service Found:", service, service.uuid)
        }
//    to remove <-- Testing
        
        if peripheral.services!.contains(where: {$0.uuid.uuidString == "25AE1441-05D3-4C5B-8281-93D4E07420CF"}) {
            print("Testing Service Connected")
        }
    }
    
//    FUNCTION CALLS
    
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
    
    func disconnectDevice(_ device: Device){
        manager.cancelPeripheralConnection(device.peripheral)
    }
}

struct Device: Identifiable {
    let name: String
    let id: UUID
    let peripheral: CBPeripheral
}

struct AllDeviceScannerHomepage: View {

    @StateObject private var scanner = DeviceScanner(targetDeviceNames: nil)
    
    var body: some View {
        NavigationStack {
            
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
                        if device.name == scanner.connectedDevice?.name {
                            scanner.disconnectDevice(device)
                        } else {
                            scanner.connectDevice(device)
                        }
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
            }
        }
    }
}

#Preview {
    AllDeviceScannerHomepage()
}
