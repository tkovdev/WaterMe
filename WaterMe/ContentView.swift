//
//  ContentView.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-17.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    
    var body: some View {
        VStack {
            Button("Add", systemImage: "plus", action: {
                Task {
                    await healthManager.addTodayWater()
                    await healthManager.fetchTodayWater()
                    await healthManager.fetchMostRecentWater()
                }
            })
            .labelStyle(.iconOnly)
            .padding(10)
            
            Text(String(format: "%.0f ml", healthManager.consumption[.startOfToday] ?? 0))
            
            Button("Remove", systemImage: "minus", action: {
                Task {
                    await healthManager.removeTodayWater()
                    await healthManager.fetchTodayWater()
                    await healthManager.fetchMostRecentWater()
                }
            })
            .labelStyle(.iconOnly)
            .padding(10)
        }
    }
}

#Preview {
    ContentView()
}
