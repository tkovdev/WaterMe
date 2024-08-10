//
//  SettingsViewModel.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-28.
//

import Foundation
import NotificationCenter

class SettingsViewModel: ObservableObject {
    @Published var increment = UserDefaults.standard.double(forKey: "increment")
    @Published var goal = UserDefaults.standard.double(forKey: "goal")
    @Published var notificationsDenied: Bool = false
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @Published var notificationStartTime: Date = UserDefaults.standard.object(forKey: "notificationStartTime") as? Date ?? Date()
    @Published var notificationEndTime: Date = UserDefaults.standard.object(forKey: "notificationEndTime") as? Date ?? Date()
    @Published var notificationDays: [Day] = [Day]()
    @Published var notifCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    init() {
        let rawNotificationDays = UserDefaults.standard.array(forKey: "notificationDays") as? [String] ?? []
        notificationDays = rawNotificationDays.compactMap { Day(rawValue: $0)}

        checkNotificationDenied()
    }
    
    func checkNotificationDenied() {
        notifCenter.getNotificationSettings() { setting in
            if(setting.authorizationStatus == UNAuthorizationStatus.denied) {
                self.notificationsDenied = true
                self.notificationsEnabled = false
                UserDefaults.standard.setValue(self.notificationsEnabled, forKey: "notificationsEnabled")
            } else {
                self.notificationsDenied = false
            }
        }
    }
    
    func requestNotificationAuth() {
        notifCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if (!success) {
                DispatchQueue.main.async {
                    self.notificationsEnabled = false
                    self.notificationsDenied = true
                }
            }
            
            if let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func removeAllNotifications() {
        notifCenter.removeAllPendingNotificationRequests()
    }

    func getNotifications() {
        notifCenter.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                debugPrint(request)
            }
        })
    }
    
    func setNotifications() async {
        // Obtain the notification settings.
        let settings = await notifCenter.notificationSettings()
        // Verify the authorization status.
        guard (settings.authorizationStatus == .authorized) ||
              (settings.authorizationStatus == .provisional) else { return }
        
        notifCenter.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "WaterMe says its water time!"
        content.body = "Have you had water in the last hour?"
//        content.categoryIdentifier = "reminder"
        content.sound = UNNotificationSound.default
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        let startHour = Calendar.current.component(.hour, from: notificationStartTime)
        let endHour = Calendar.current.component(.hour, from: notificationEndTime)
        let startMin = Calendar.current.component(.minute, from: notificationStartTime)
        let endMin = Calendar.current.component(.minute, from: notificationEndTime)
        
        let currentHour = startHour
        for currentHour in currentHour...endHour {
            dateComponents.hour = currentHour
            dateComponents.minute = startMin
               
            if(currentHour == endHour && endMin < startMin) {
                dateComponents.minute = endMin
            }
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            do {
                try await notifCenter.add(request)
            } catch {
                debugPrint("*** setNotifications() error ***")
            }
        }
    }
    
    
    //https://www.hackingwithswift.com/example-code/system/how-to-set-local-alerts-using-unnotificationcenter
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
//        let userInfo = response.notification.request.content.userInfo
//
//        if let customData = userInfo["customData"] as? String {
//            print("Custom data received: \(customData)")
//
//            switch response.actionIdentifier {
//            case UNNotificationDefaultActionIdentifier:
//                // the user swiped to unlock
//                print("Default identifier")
//
//            case "show":
//                // the user tapped our "show more info…" button
//                print("Show more information…")
//                break
//
//            default:
//                break
//            }
//        }

        // you must call the completion handler when you're done
//        completionHandler()
//    }
    
    //use this to add a button to allow for increment to be clicked
    //https://www.hackingwithswift.com/example-code/system/how-to-set-local-alerts-using-unnotificationcenter
//    func registerCategories() {
//        notifCenter.delegate = self
//
//        let show = UNNotificationAction(identifier: "increment", title: "I'm on it!", options: .foreground)
//        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
//
//        center.setNotificationCategories([category])
//    }
}
