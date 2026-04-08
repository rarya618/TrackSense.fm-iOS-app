//
//  LibraryHoursSheet.swift
//  Resonate
//
//  Created by Russal Arya on 19/11/2025.
//

import SwiftUI

struct LibraryHoursSheet: View {
    var cloudData: StatFromCloud?
    
    var body: some View {
        StatSheet(
            title: "Library Hours",
            cloudData: cloudData,
            historyDescription: "This chart shows how your total listening hours have changed over time. Data updates when content is synced to the cloud.",
            unitLabel: "hours"
        )
    }
}
