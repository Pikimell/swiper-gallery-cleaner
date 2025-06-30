//
//  ContentView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 30.06.2025.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .background(theme.background)
    }
}

#Preview {
    ContentView()
}
