//
//  DataDisplayPage.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/8/26.
//

import SwiftUI

struct WaitingForRep: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 275)
            Text("Waiting for Rep to Start")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue.gradient)
            Spacer()
                .frame(height: 50)
            VStack (spacing: 20) {
                HStack{
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
