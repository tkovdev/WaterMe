//
//  SettingsView.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @State var number = UserDefaults.standard.double(forKey: "increment")
    
    var body: some View {
        Form {
            Section(header: Text("Consumption")){
                List {
                    LabeledContent("\(healthManager.results.units.formatted())") {
                        TextField("Increment By", value: $number, format: .number, prompt: Text("Increment By"))
                        .multilineTextAlignment(.trailing)
                        .onSubmit() {
                            UserDefaults.standard.setValue(self.number, forKey: "increment")
                        }
                    }
                }
                Text("Change units in the [Health](x-apple-health://) app")
                    .fontWeight(.light)
                    .font(.caption)
            }
        }
    }
}

