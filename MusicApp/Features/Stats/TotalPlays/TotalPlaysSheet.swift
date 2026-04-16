//
//  TotalPlaysSheet.swift
//  Resonate
//
//  Created by Russal Arya on 19/11/2025.
//

import SwiftUI

struct TotalPlaysSheet: View {
    var cloudData: StatFromCloud?
    
    var body: some View {
        StatSheet(
            title: "Total Plays",
            cloudData: cloudData,
            historyDescription: "This chart shows how your total plays have changed over time. Data updates when content is synced to the cloud.",
            unitLabel: "plays"
        )
    }
}
