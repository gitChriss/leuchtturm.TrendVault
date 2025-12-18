//
//  ContentView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack(spacing: 12) {
            Text("TrendVault")
                .font(.title)
                .fontWeight(.semibold)

            Text("Creative Studio")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
