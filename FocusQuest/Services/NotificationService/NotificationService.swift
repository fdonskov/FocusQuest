import Foundation
import UserNotifications

enum NotificationService {
    private static let center = UNUserNotificationCenter.current()
    private static let sessionEndID = "session_end"
    private static let streakReminderID = "streak_reminder"

    static func requestAuthorization() {
        center.delegate = NotificationDelegate.shared
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func scheduleSessionEnd(after seconds: TimeInterval) {
        cancelSessionEnd()
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Сессия завершена"
        content.body = "Фокус-сессия окончена. Заберите награду."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        center.add(UNNotificationRequest(identifier: sessionEndID, content: content, trigger: trigger))
    }

    static func cancelSessionEnd() {
        center.removePendingNotificationRequests(withIdentifiers: [sessionEndID])
    }

    static func scheduleStreakReminder(hour: Int = 20, minute: Int = 0) {
        cancelStreakReminder()
        let content = UNMutableNotificationContent()
        content.title = "Не теряйте стрик"
        content.body = "Загляните в FocusQuest и проведите фокус-сессию сегодня."
        content.sound = .default
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: streakReminderID, content: content, trigger: trigger))
    }

    static func cancelStreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [streakReminderID])
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
