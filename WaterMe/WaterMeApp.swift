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
            NavigationStack {
                if(healthManager.healthStore.authorizationStatus(for: HKQuantityType(.dietaryWater)) == HKAuthorizationStatus.sharingAuthorized){
                    MainView()
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarLeading){
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    Image(systemName: "gearshape")
                                }
                            };
                            ToolbarItem(placement: .navigationBarTrailing){
                                NavigationLink {
                                    CustomAdd()
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                            }
                        }).task {
                            await healthManager.fetchUserUnitPreference()
                        }
                        .tint(.blue)
                }else{
                    VStack(spacing: 16){
                        Image("permissionScreen")
                            .resizable()
                            .scaledToFit()
                        Text("Permission Required!").font(.headline)
                        Text("WaterMe requires read and write permission to your Health data.").font(.subheadline)
                        Text("Go to [Settings > Privacy & Security > Health](App-prefs:root) and allow \"WaterMe\" access to read and write.")
                        .font(.caption)
                        .padding(10)
                    }.padding(20)
                }
            }
        }.environmentObject(healthManager)
    }
}
