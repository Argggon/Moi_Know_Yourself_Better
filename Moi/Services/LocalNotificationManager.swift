import Foundation
import UserNotifications

public final class LocalNotificationManager {
    public static let shared = LocalNotificationManager()
    
    private init() {}
    
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification Authorization Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedule daily question reminder at specified hour/minute
    public func scheduleDailyQuestionReminder(time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["moi_daily_question"])
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        let content = UNMutableNotificationContent()
        content.title = "Moi"
        content.body = "今日问题已生成，来映照此刻的自己吧。"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "moi_daily_question", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    /// Schedule monthly story notification
    public func scheduleMonthlyStoryNotification(dayOfMonth: Int, time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["moi_monthly_story"])
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.day = dayOfMonth
        
        let content = UNMutableNotificationContent()
        content.title = "Moi"
        content.body = "你的月度故事已生成，点击开启这封写给你的信。"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "moi_monthly_story", content: content, trigger: trigger)
        
        center.add(request)
    }
}
