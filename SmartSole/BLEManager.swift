//
//  Untitled.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/6/26.
//

import SwiftUI
import CoreBluetooth
import Combine
import RealityKit
import Spatial

class BLEManager:
        NSObject,
        CBCentralManagerDelegate,
        ObservableObject,
        CBPeripheralDelegate {
    
    @Published var state: CBManagerState = .unknown
    @Published var isScanning: Bool = false
    @Published var foundDevices: [Device] = []
    @Published var connectedDevices: [Device] = []
    @Published var allData: [RunData] = []
    @Published var currentData: RunData = RunData(accels: "Connect Device",
                                              angles: simd_quatf(),
                                              angleAccels: "Connect Device")
    
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
            connectedDevices.append(device)
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
        if let error = error {
            print("Service Discovery Error:", error)
        }
        
//    Testing --> to remove
        guard let services = peripheral.services else {
            print("No Services")
            return
        }
        for service in services {
            print("Service Found:", service, service.uuid)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: (any Error)?
    ) {
        if let error = error {
            print("Char Discover Error:", error)
        }

        guard let characteristics = service.characteristics else {
            print("no characteristics");
            return
        }
        
        print("Found Characteristics for:", service.uuid)
        print("count:", characteristics.count)
        print("Characteristics:")
        
        for char in characteristics {
            peripheral.setNotifyValue(true, for: char)
            print("-", char)
        }
        print()
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        if let error = error {
            print("Notification Error:", error)
        }
        
        print("Recieving Notifications from:", characteristic)
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        if let error = error {
            print("Value Update Error:", error)
            return
        }
        if characteristic.uuid.uuidString.prefix(8) == "C7304342" {
            handleData(characteristic.value)
        }
    }
    
//    FUNCTION CALLS
    
    func startScan() {
        print("Starting Scan")
        foundDevices.removeAll()
        isScanning = true
        manager.scanForPeripherals(withServices: nil)
    }
    
    func stopScan() {
        print("Stopping Scan")
        isScanning = false
        manager.stopScan()
    }
    
    func connectDevice(_ device: Device) {
        manager.connect(device.peripheral)
    }
    
    func disconnectDevice(_ device: Device){
        manager.cancelPeripheralConnection(device.peripheral)
    }
    
    // HANDLE CHARACTERISTIC UPDATES
    private func handleData(_ data: Data?) {
        let values = String(bytes: data!, encoding: .utf8)!.split(separator: ";")
        
        let str_angles = values[1].split(separator: ",")
        let q0 = Float(str_angles[0])!
        let q1 = Float(str_angles[1])!
        let q2 = Float(str_angles[2])!
        let q3 = Float(str_angles[3])!

        let orientation = simd_quatf(ix: q1, iy: q2, iz: q3, r: q0)
        
        // Update with new values
        self.currentData = RunData(accels: String(values[0]), angles: orientation, angleAccels: String(values[2]))
        self.allData.append(self.currentData)
    }
}

struct Device: Identifiable {
    let name: String
    let id: UUID
    let peripheral: CBPeripheral
}

struct RunData {
    let accels: String
    let angles: simd_quatf
    let angleAccels: String
}

struct AllDeviceScannerHomepage: View {

    @StateObject private var bleManager = BLEManager(targetDeviceNames: nil)
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Text("BLE Devices")
                    .fontWeight(.thin)
                    .font(.largeTitle)
                Button(action: {
                    bleManager.startScan()
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
                List(bleManager.foundDevices) { device in
                    Button(action: {
                        print("DEVICE PRESSED: \(device.name) - \(device.id)")
                        if bleManager.connectedDevices.contains(where: {
                            $0.name == device.name
                        }) {
                            bleManager.disconnectDevice(device)
                        } else {
                            bleManager.connectDevice(device)
                        }
                    }) {
                        HStack {
                            Text(device.name)
                            Spacer()
                            Text(device.id.uuidString.prefix(4))
                                .font(.footnote)
                                .fontWeight(.ultraLight)
                        }
                        .padding()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}
