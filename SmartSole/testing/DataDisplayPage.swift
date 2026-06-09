//
//  DataDisplayPage.swift
//  SmartSole
//
//  Created by Daniel Slater on 6/8/26.
//

import SwiftUI


struct DataDisplayPage: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Spacer()
            
            Text("Waiting For Rep to Start")
            
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
                    .opacity(0.5)
            )
            .foregroundStyle(.red.opacity(0.5).gradient)
            .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden()
    }
}
