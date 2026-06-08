    //
//  Homepage.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/7/26.
//

import SwiftUI

struct Homepage: View {
    var body: some View {
        NavigationStack {
            VStack (spacing: 20) {
                Section {
                    Text("SmartSole")
                        .font(.custom("Title", fixedSize: 55))
                        .fontWeight(.medium)
                        .foregroundStyle(.blue.gradient)
                }
                Image("yupwegotone-medium")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(50)

                NavigationLink(destination: DeviceFamilyFinder()) {
                    Text("Start Analysis")
                        .frame(maxWidth: .infinity)
                }
            }
            .fontWeight(.thin)
            .font(.title)
            .foregroundStyle(.blue.gradient)
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.glass)
            .padding(.horizontal, 35)
        }
    }
}


#Preview {
    Homepage()
}
