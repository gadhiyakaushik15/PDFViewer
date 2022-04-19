//
//  AppDelegate.swift
//  PDFViewer
//
//  Created by Macbook Pro on 04/05/18.
//  Copyright © 2018 Kaushik Gadhiya. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase
import FirebaseMessaging
import UserNotifications

let appDelegate = UIApplication.shared.delegate as! AppDelegate

let googleAdsID = "ca-app-pub-8576867486596636~6351002112"

// Test ID
//let adsBannerID = "ca-app-pub-3940256099942544/2934735716"
//let adsInterstitialID = "ca-app-pub-3940256099942544/4411468910"
// Live ID
let adsBannerID = "ca-app-pub-8576867486596636/1829604493"
let adsInterstitialID = "ca-app-pub-8576867486596636/1304180259"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if !UserDefaults.standard.bool(forKey: "isAddFile")
        {
            UserDefaults.standard.set(true, forKey: "isAddFile")
            
            let sampleFilename = "swift_tutorial.pdf"
            if let sampleFile = Bundle.main.url(forResource: sampleFilename, withExtension: nil) {
                let destination = documentDirectory.appendingPathComponent(sampleFilename)
                if !fileManager.fileExists(atPath: destination.path) {
                    try? fileManager.copyItem(at: sampleFile, to: destination)
                }
            }
        }
        
        if let launchOptions = launchOptions, let url = launchOptions[.url] as? URL {
            let destination = documentDirectory.appendingPathComponent(url.lastPathComponent)
            if !fileManager.fileExists(atPath: destination.path) {
                try? fileManager.copyItem(at: url, to: destination)
                NotificationCenter.default.post(name: .documentDirectoryDidChange, object: nil)
            }
        }
        
        // TODO: Push Notification
        self.setupPushNotification(application)
        
        // Firebase Configration
        FirebaseApp.configure()
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().delegate = self
        
        // Fabric Configration
        Fabric.with([Crashlytics.self])
        
        // Google AdsMob Configration
        GADMobileAds.sharedInstance().start()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options:[UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination = documentDirectory.appendingPathComponent(url.lastPathComponent)
        if !fileManager.fileExists(atPath: destination.path) {
            try? fileManager.copyItem(at: url, to: destination)
            NotificationCenter.default.post(name: .documentDirectoryDidChange, object: nil)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: Setup push notification
    func setupPushNotification(_ application: UIApplication)
    {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
    }
    
    
    // MARK: - Firebase Messaging Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?)
    {
        print("FCM Token: \(fcmToken ?? "")")
    }
    
    // MARK: - Push Notification Delegate
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("APNs registration failed: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        completionHandler()
    }

    
}

