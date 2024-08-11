//
//  SettingsView.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-20.
//

import SwiftUI
import NotificationCenter

struct SettingsView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @ObservedObject var viewModel: SettingsViewModel = SettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Consumption Increment")) {
                List {
                    LabeledContent("\(healthManager.results.units.formatted())") {
                        TextField("Increment By", value: $viewModel.increment, format: .number, prompt: Text("Increment By"))
                            .multilineTextAlignment(.trailing)
                            .onSubmit() {
                                UserDefaults.standard.setValue(viewModel.increment, forKey: "increment")
                            }
                    }
                }
                Text("Change units in the [Health](x-apple-health://) app.")
                    .fontWeight(.light)
                    .font(.caption)
            }
            Section(header: Text("Daily Reminder")){
                Toggle(isOn: $viewModel.notificationsEnabled) {
                    Text("Notifications")
                }
                .onChange(of: viewModel.notificationsEnabled){
                    UserDefaults.standard.setValue(viewModel.notificationsEnabled, forKey: "notificationsEnabled")
                    viewModel.requestNotificationAuth()
                    if(viewModel.notificationsEnabled){
                        Task {
                            await viewModel.setNotifications()
                        }
                    } else {
                        viewModel.removeAllNotifications()
                    }
                }
                .disabled(viewModel.notificationsDenied)
                if(viewModel.notificationsDenied){
                    Text("Notifications have been disabled. Enable notifications in [Settings](App-prefs://) app.")
                        .fontWeight(.light)
                        .font(.caption)
                }
                if(viewModel.notificationsEnabled && !viewModel.notificationsDenied) {
                    List {
//                        LabeledContent("\(healthManager.results.units.formatted())/day") {
//                            TextField("Daily Goal", value: $viewModel.goal, format: .number, prompt: Text("Daily Goal"))
//                                .multilineTextAlignment(.trailing)
//                                .onSubmit() {
//                                    UserDefaults.standard.setValue(viewModel.goal, forKey: "goal")
//                                    Task {
//                                        await viewModel.setNotifications()
//                                    }
//                                }
//                        }
                        DatePicker("From", selection: $viewModel.notificationStartTime, displayedComponents: .hourAndMinute)
                            .onChange(of: viewModel.notificationStartTime) {
                                UserDefaults.standard.set(viewModel.notificationStartTime, forKey: "notificationStartTime")
                                Task {
                                    await viewModel.setNotifications()
                                }
                            }
                        DatePicker("Until",
                                   selection: $viewModel.notificationEndTime,
                                   displayedComponents: .hourAndMinute)
                            .onChange(of: viewModel.notificationEndTime) {
                                UserDefaults.standard.set(viewModel.notificationEndTime, forKey: "notificationEndTime")
                                Task {
                                    await viewModel.setNotifications()
                                }
                            }
//                        DaysPicker(selection: $viewModel.notificationDays) {
//                            UserDefaults.standard.set(viewModel.notificationDays.map { $0.rawValue}, forKey: "notificationDays")
//                        }
                    }
                }
                Text("Daily notifications are sent every hour between the From & Until times.")
                    .fontWeight(.light)
                    .font(.caption)
            }
        }
    }
}

