//
//  NTSAppDelegate.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import UIKit

@UIApplicationMain
class NTSAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// A Reachability instance
    let reachability = NTSReachability()
    /// A Boolean which identifies whether the network is reachable or not
    var isReachable = true
    /// A static AppDelegate instance which can be retrieved from anywhere of the app
    static var appDelegateInstance: NTSAppDelegate? {
        if Thread.isMainThread {
            return UIApplication.shared.delegate as? NTSAppDelegate
        }
        return nil
    }
    private var initialViewController: NTSPhotoListController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // configure first view controller and reachability class
        configureReachability()
        configureWindow()
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
}

extension NTSAppDelegate {
    /// Configures the window using the mocking view controller as the root
    private func configureWindow() {
        // Initial view controller will be displayed first
        if let initViewController = UIViewController.getViewController(ofType: NTSPhotoListController.self, fromStoryboardName: StoryboardId.photoViewer, storyboardId: NTSPhotoListController.className, bundle: .main) {
            initialViewController = initViewController
            let model = NTSPhotoListViewModel()
            initViewController.bind(to: model)
        }
        configureWindow(with: initialViewController)
    }
    
    private func configureWindow(with rootVC: UIViewController?) {
        if let root = rootVC {
            let navigationController = UINavigationController(rootViewController: root)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.backgroundColor = UIColor.lightGray
            window?.makeKeyAndVisible()
        }
    }
    //MARK: Configure Reachability
    private func configureReachability() {
        // Observer network changes
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        // Start Reachability Notifier
        do {
        try reachability?.startNotifier()
        if let connection = reachability?.connection, connection == .none {
            isReachable = false
        } else {
            isReachable = true
        }
        } catch {
            print("couldn't start reachability notifier")
        }
    }
    
    //MARK: Reachability handler
    @objc
    func reachabilityDidChange(notification: Notification) {
        if let reachability = notification.object as? NTSReachability {
            switch reachability.connection {
            case .wifi:
                print("Reachable via Wifi")
                isReachable = true
            case .cellular:
                print("Reachable via Cellular")
                isReachable = true
            case .none:
                print("Network is not reachable")
                isReachable = false
            }
        }
    }
}
