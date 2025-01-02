//
//  MainView.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-20.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    
    var body: some View {
        VStack {
            Button("Add", systemImage: "plus", action: {
                Task {
                    await healthManager.addTodayWater()
                    await healthManager.fetchTodayWater()
                    healthManager.fetchMostRecentWater()
                }
            })
            .labelStyle(.iconOnly)
            .padding(10)
            
            HStack {
                Text(healthManager.results.consumption.doubleValue(for: healthManager.results.units), format: .number.precision(.fractionLength(0)))
                Text(healthManager.results.units.formatted())
            }
            Button("Remove", systemImage: "minus", action: {
                Task {
                    await healthManager.removeTodayWater()
                    await healthManager.fetchTodayWater()
                    healthManager.fetchMostRecentWater()
                }
            })
            .labelStyle(.iconOnly)
            .padding(10)
        }
    }
}
#Preview {
    MainView().environmentObject(HealthKitManager())
}
