//
//  WaterMeApp.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-17.
//

import SwiftUI
import HealthKit

@main
struct WaterMeApp: App {
    @StateObject var healthManager: HealthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(healthManager)
        }
    }
}
