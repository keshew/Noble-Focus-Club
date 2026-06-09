import FirebaseCore
import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

final class Z9Bridge: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    static var zMask = UIInterfaceOrientationMask.allButUpsideDown
    private static let qA17 = DispatchQueue(label: "q.z.17")
    private static var sA17: String = ""
    private static var tA17: Date = .distantPast

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Z9Bridge.zMask
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self

        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().token { token, error in
            if let error {
                print("a0.e \(error.localizedDescription)")
                return
            }
            print("a0.v")
            self.storeA0(token, source: "s0")
        }

        let authorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions) { _, _ in }
        application.registerForRemoteNotifications()

        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            Messaging.messaging().appDidReceiveMessage(userInfo)
            let pushIdentifier = storeB1(userInfo, source: "p0")
            emitB1(pushId: pushIdentifier, source: "p0")
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        let apnsToken = deviceToken.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(apnsToken, forKey: "k_a0")
        print("b0")

        Messaging.messaging().token { token, error in
            if let error {
                print("a1.e \(error.localizedDescription)")
                return
            }
            print("a1.v")
            self.storeA0(token, source: "s1")
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        storeB1(userInfo, source: "p1")
        completionHandler([.list, .banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        let pushIdentifier = storeB1(userInfo, source: "p2")
        emitB1(pushId: pushIdentifier, source: "p2")
        completionHandler()
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        let pushIdentifier = storeB1(userInfo, source: "p3")
        emitB1(pushId: pushIdentifier, source: "p3")
        completionHandler(.newData)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        storeA0(fcmToken, source: "s2")
    }
}

private extension Z9Bridge {
    func storeA0(_ token: String?, source: String) {
        let normalizedToken = token?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let normalizedToken, !normalizedToken.isEmpty {
            UserDefaults.standard.set(normalizedToken, forKey: "k_f0")
            print("a2(\(source))")
            print("a2.v")
            NotificationCenter.default.post(
                Notification(name: NSNotification.Name("e0"), object: nil)
            )
            return
        }

        UserDefaults.standard.set("null", forKey: "k_f0")
        print("a2(\(source)): null")
        print("a2.n")
    }

    func emitB1(pushId: String?, source: String) {
        let normalizedPushId = pushId?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let signature = normalizedPushId.isEmpty ? "empty:\(source)" : normalizedPushId
        let now = Date()

        let shouldDispatch = Z9Bridge.qA17.sync { () -> Bool in
            let elapsed = now.timeIntervalSince(Z9Bridge.tA17)
            let isDuplicate = (Z9Bridge.sA17 == signature) && elapsed < 2.0
            if isDuplicate {
                return false
            }
            Z9Bridge.sA17 = signature
            Z9Bridge.tA17 = now
            return true
        }

        guard shouldDispatch else {
            print("b1.skip \(source)")
            return
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("n.c.e1"), object: nil)
        }
    }

    func txtA0(_ value: Any?) -> String? {
        guard let value else { return nil }
        let text = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    func pickB1(from object: Any) -> String? {
        if let dictionary = object as? [String: Any] {
            if let direct = txtA0(dictionary["push_id"]) { return direct }
            if let direct = txtA0(dictionary["gcm.notification.push_id"]) { return direct }
            if let nested = dictionary["push_data"], let id = pickB1(from: nested) { return id }
            if let nested = dictionary["data"], let id = pickB1(from: nested) { return id }
            return nil
        }

        if let dictionary = object as? [AnyHashable: Any] {
            if let direct = txtA0(dictionary["push_id"]) { return direct }
            if let direct = txtA0(dictionary["gcm.notification.push_id"]) { return direct }
            if let nested = dictionary["push_data"], let id = pickB1(from: nested) { return id }
            if let nested = dictionary["data"], let id = pickB1(from: nested) { return id }
            return nil
        }

        if let text = object as? String,
           let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) {
            return pickB1(from: json)
        }

        return nil
    }

    @discardableResult
    func storeB1(_ userInfo: [AnyHashable: Any], source: String) -> String? {
        if let pushId = pickB1(from: userInfo as Any), !pushId.isEmpty {
            UserDefaults.standard.set(pushId, forKey: "k_p0")
            print("b1(\(source))")
            if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: [.prettyPrinted]),
               let text = String(data: data, encoding: .utf8) {
                UserDefaults.standard.set(text, forKey: "k_p1")
            }
            return pushId
        }

        print("b1(\(source)) nil")
        if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: [.prettyPrinted]),
           let text = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(text, forKey: "k_p1")
        }
        return nil
    }
}
