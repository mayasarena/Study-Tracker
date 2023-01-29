//
//  NotificationManager.swift
//  Study Tracker
//
//  Created by Maya Murad on 2023-01-25.
//

import SwiftUI
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "timerReminder") == nil {
            defaults.set(7200, forKey: "timerReminder")
            print("timer reminder set")
        }
        
        if defaults.object(forKey: "reminderNotificationOn") == nil {
            defaults.set(true, forKey: "reminderNotificationOn")
            print("timer reminder set true")
        }
    }
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("ERROR: \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    func scheduleTimerReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Are you still studying?"
        content.subtitle = "Your timer is still running! Don't forget to stop it (or take a study break)."
        content.sound = .default
        content.badge = 0
        
        //triggers:
        // time
        let defaults = UserDefaults.standard
        
        let timeInterval = defaults.double(forKey: "timerReminder")
        print("time interval:")
        print(timeInterval)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: true)
        // calendar
        
//        var dateComponents = DateComponents()
//        dateComponents.hour = 15
//        dateComponents.minute = 2
        
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        // location
        
        let request = UNNotificationRequest(
            identifier: "timerReminder",
            content: content,
            trigger: trigger)
        
        if defaults.bool(forKey: "reminderNotificationOn") == true {
            UNUserNotificationCenter.current().add(request)
            print("Scheduled timer reminder notification")
        }
        else {
            print("Notification off")
        }
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
            }
        })
    }
    
    func cancelTimerReminderNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled timer reminder notification")
    }
}

struct NotificationManagerView: View {
    var body: some View {
        VStack {
            Button("Request permission") {
                NotificationManager.instance.requestAuthorization()
            }
            
            Button("Schedule notification") {
                NotificationManager.instance.scheduleTimerReminderNotification()
            }
        }
        .onAppear {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

struct NotificationManagerView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationManagerView()
    }
}

func SecondsToHoursMinutes(seconds: Int) -> String {
    let hour = "\(seconds / 3600)"
    let min = "\((seconds % 3600) / 60)"
    if Int(hour) == 0 {
        return "\(min) min"
    }
    else if Int(min) == 0 {
        return "\(hour) hr"
    }
    return "\(hour) hr \(min) min"
}
