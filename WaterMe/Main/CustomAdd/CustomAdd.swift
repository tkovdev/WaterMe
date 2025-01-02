//
//  CustomAdd.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-12-29.
//

import SwiftUI

struct CustomAdd: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @State var customAmount: Double = 0
    
    var body: some View {
        Form {
            Section(header: Text("Add more")) {
                List {
                    LabeledContent("\(healthManager.results.units.formatted())") {
                        TextField("Increment By", value: $customAmount, format: .number, prompt: Text("Increment By"))
                            .multilineTextAlignment(.trailing)
                            .onSubmit() {
                                Task {
                                    await healthManager.addTodayWater(customAmount: customAmount)
                                    await healthManager.fetchTodayWater()
                                    healthManager.fetchMostRecentWater()
                                    customAmount = 0
                                }
                            }
                    }
                }
            }
            Section(header: Text("Total")) {
                HStack {
                    Text(healthManager.results.consumption.doubleValue(for: healthManager.results.units), format: .number.precision(.fractionLength(0)))
                    Text(healthManager.results.units.formatted())
                }
            }
        }
    }
}

#Preview {
    CustomAdd().environmentObject(HealthKitManager())
}
