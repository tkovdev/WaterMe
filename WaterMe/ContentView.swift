//
//  ContentView.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-17.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var healthManager: HealthKitManager
    
    init(healthManager: HealthKitManager) {
        self.healthManager = healthManager
    }
    
    var body: some View {
        NavigationStack {
            ToolbarItem(placement: .navigationBarLeading){
                NavigationLink("Profile", destination: ProfileView())
            }
        }
    }
}
