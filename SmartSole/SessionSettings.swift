//
//  InsoleData.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/7/26.
//

import SwiftUI

struct SessionSettings: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var bleManager: BLEManager
    
    let selectedDevices: [Device] // Insole, Arm Sleeve, Leg Sleeve, Chest Strap, etc.
    
    @State private var selectedShoeType = "Spikes" //  Spikes, Flats
    @State private var selectedRunType = "Sprints" //   Sprints, Distance
    
    private let shoeTypes = ["Spikes", "Flats"]
    private let runTypes = ["Sprints", "Distance"]
        
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Session Settings")
                    .font(.largeTitle)
                    .fontWeight(.thin)
                Text("Selected Devices:")
                    .font(.title2)
                    .fontWeight(.thin)
                    .foregroundStyle(.blue.gradient)
            }
            Spacer()
                .frame(height: 20)
            List(selectedDevices) { device in
                HStack {
                    Text(device.name)
                        .fontWeight(.thin)
                        .foregroundStyle(.blue.gradient)
                    Spacer()
                    Text(device.id.uuidString.prefix(4))
                        .fontWeight(.ultraLight)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
            .buttonStyle(.glass)
            .frame(width: 350, height: 250)
            .scrollContentBackground(.hidden)
            .background(
                self.colorScheme == .dark ?
                Color(red: 0.075, green: 0.075, blue: 0.075) :
                    Color(red: 0.925, green: 0.925, blue: 0.925)
            )
            .cornerRadius(12)
            Spacer()
                .frame(height: 75)
            VStack (spacing: 15) {
                Text("Run Type")
                    .font(.headline)
                    .fontWeight(.thin)
                    .foregroundStyle(.blue.gradient)
                Picker("Run Type", selection: $selectedRunType) {
                    ForEach(runTypes, id: \.self) { runType in
                        Text(runType)
                    }
                }
                Divider()
                Text("Shoe Type")
                    .font(.headline)
                    .fontWeight(.thin)
                    .foregroundStyle(.blue.gradient)
                Picker("Shoe Type", selection: $selectedShoeType) {
                    ForEach(shoeTypes, id: \.self) { shoeType in
                        Text(shoeType)
                    }
                }
                Divider()
                Spacer()
                    .frame(height: 35)
            }
            .padding(.horizontal, 75)
            .pickerStyle(.segmented)
            .scaleEffect(1.5)
            NavigationLink(destination: WaitingForRep(bleManager: bleManager)) {
                Text("Start Rep")
                    .font(.title)
                    .padding()
                    .padding(.horizontal, 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke()
                            .foregroundStyle(.blue.gradient)
                    )
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
