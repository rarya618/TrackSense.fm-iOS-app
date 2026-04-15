//
//  InlineSearchBar.swift
//  Resonate
//
//  Created by Russal Arya on 14/11/2025.
//

import SwiftUI

struct InlineSearchBar: View {
    @Binding var searchText: String
    let label: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(label, text: $searchText)
                .tracking(17 * -0.025)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .glassEffect(.regular.interactive())
    }
}
