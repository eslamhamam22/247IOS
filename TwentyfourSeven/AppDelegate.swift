//
//  AppDelegate.swift
//  TwentyfourSeven
//
//  Created by Salma Ali on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Firebase
//import GoogleSignIn
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import OneSignal
import Kingfisher
import UserNotifications
//import Fabric
//import Crashlytics
import Cosmos
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var window: UIWindow?
    var isRTL: Bool = true
    let userDefault = UserDefault()
    var userRepository: UserRepository!
    var myDirection : NSTextAlignment?
    var cityName = ""
    var isNotificationAllowed = false
    var isFromNotifications = false
    var blockedAreas = [BlockedArea]()
    var myOrdersNeedUpdate = false
    var currentOrdersNeedUpdate = false
    let databaseManager = DatabaseManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//              Fabric.with([Crashlytics.self])
                //light ontent of status bar text
//        UIApplication.shared.statusBarStyle = .lightContent
        
//        UINavigationBar.appearance().barStyle = .default

        integrateWithOneSignal(launchOptions: launchOptions, application: application)
        
        if(userDefault.getLanguage() == nil){
            //remove initial value related to phone language and set it ar by default
            
//            let langStr = Locale.current.languageCode
//            if langStr != nil{
//                if (langStr?.contains("en"))!{
//                    setLangauge("en")
//                }else{
//                    setLangauge("ar")
//                }
//            }else{
//                setLangauge("en")
//            }
            setLangauge("ar")

        }else{
            initLanguage()
        }
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                if let paramters = params as? [String: AnyObject]{
                    if let id = paramters["id"] as? String{
                        print("store id = \(id)")
                        let storyboard = UIStoryboard(name: "StoreDetails", bundle: nil)
                        let destinationNavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
                        let targetController = destinationNavigationController.topViewController as! StoreDetailsVC
                        targetController.placeID = id
                        targetController.isStoreLoaded = false
                        targetController.isFromShare = true
                        self.isFromNotifications = true
                        self.window?.rootViewController = destinationNavigationController
                        self.window?.makeKeyAndVisible()
                    }
                }
                print("params: %@", params as? [String: AnyObject] ?? {})
            }
        })
        
        // Initialize sign-in
//        GIDSignIn.sharedInstance().clientID = AppKeys.CLIENT_ID
//        GIDSignIn.sharedInstance().delegate = self
        GMSServices.provideAPIKey(AppKeys.API_KEY)
        GMSPlacesClient.provideAPIKey(AppKeys.API_KEY)
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL?, sourceApplication: sourceApplication, annotation: annotation)
        }
        
         FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL?, sourceApplication: sourceApplication, annotation: annotation)
        
        return true

        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        
//        if(url.absoluteString.contains("TwentyFour7://"))
//        {
//            url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
//            print("url host : \(String(describing: url.host))")
//            print("url path : \(url.path)")
//            let storyboard = UIStoryboard(name: "StoreDetails", bundle: nil)
//            let destinationNavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
//            let targetController = destinationNavigationController.topViewController as! StoreDetailsVC
//            if(url.host != nil){
//                targetController.placeID = "ChIJsfGmhL3E9RQRWsWIFcFY3A4"
//                targetController.isStoreLoaded = false
//                targetController.isFromShare = true
//            }
//
//            self.isFromNotifications = true
//            window?.rootViewController = destinationNavigationController
//            return true
//        }else{
//            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL?, sourceApplication: sourceApplication, annotation: annotation)
//        }
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        _ = FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL?,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        
//        _ =  GIDSignIn.sharedInstance().handle(url as URL?,
//                                               sourceApplication: options [UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                                               annotation: options[UIApplication.OpenURLOptionsKey.annotation])

        
//        if(url.absoluteString.contains("TwentyFour7://"))
//        {
//            url = url + "?token=" + userDefault.getToken()!
        print("url \(url)")
//            print("url host : \(String(describing: url.host))")
//            print("url path : \(url.path)")
//            let storyboard = UIStoryboard(name: "StoreDetails", bundle: nil)
//            let destinationNavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
//            let targetController = destinationNavigationController.topViewController as! StoreDetailsVC
//            if(url.host != nil){
//                targetController.placeID = url.host!
//                targetController.isStoreLoaded = false
//                targetController.isFromShare = true
//            }
//
//            self.isFromNotifications = true
//            window?.rootViewController = destinationNavigationController
//        }
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        return true
    }

    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance().handle(url as URL?,
//                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
//    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//
//        
//        if (error == nil) {
//            let idToken = user.authentication.accessToken
//            print("google token \(idToken!)")
//
//            if user.profile.hasImage
//            {
//
//                let p = user.profile.imageURL(withDimension: 100)
//                print(user.profile.givenName)
//                print(user.profile.email)
//                print(user.profile.familyName)
//
//                if p != nil{
////                    self.userDefault.setProfileImage(p?.absoluteString)
//                    print("profile image = \(String(describing: p?.absoluteString))")
//                }
//                print(p?.absoluteString ?? "")
//            }
//            userRepository.getGoogleToken(idToken!)
//
//        } else {
//            print("\(error.localizedDescription)")
//            userRepository.getGoogleToken("error")
//        }
//    }
//
//
    func loginWithGoogle(_ loginRepository: UserRepository) {
//        self.userRepository = loginRepository
//
//        let signin = GIDSignIn.sharedInstance()
//        signin?.shouldFetchBasicProfile = true
//        signin?.clientID = AppKeys.CLIENT_ID
////        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/userinfo.profile")
////        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
////        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
//        signin?.delegate = self
//        signin?.delegate = self
//
//
//        //signin?.signInSilently()
//
//        signin?.signIn()
    }
    
    static func getInstance() -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        bgTask = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskIdentifier.invalid
        })
        databaseManager.checkDelagateLocation()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    
}

//This extension is resposible for one signal integration
extension AppDelegate : OSSubscriptionObserver, OSPermissionObserver , UNUserNotificationCenterDelegate{
    
    func integrateWithOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]? , application: UIApplication){
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: AppKeys.ONE_SIGNAL_APPID,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        if onesignalInitSettings["kOSSettingsKeyAutoPrompt"] == false
        {
          OneSignal.addTrigger("prompt_ios", withValue: "true")
        }
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            if accepted{
                self.isNotificationAllowed = true
            }else{
                self.isNotificationAllowed = false
            }
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let playerID = status.subscriptionStatus.userId
            if playerID != nil{
                print("got playerID")
                self.userDefault.setPlayerID(playerID!)
            }
            else
            {
                self.userDefault.setPlayerID("D4CCA271-A6D1-4E68-BFE9-6AFF67B3D486")
            }
        })
        
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.add(self as OSSubscriptionObserver)
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let playerID = status.subscriptionStatus.userId
        if playerID != nil{
            print("got playerID")
            self.userDefault.setPlayerID(playerID!)
        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {

        if (!stateChanges.from.subscribed && stateChanges.to.subscribed) || (stateChanges.from == nil && stateChanges.to.subscribed){
            // get player ID
            let playerId = stateChanges.to.userId
            if playerId != nil{
                print("got playerID")
                print("onOSSubscriptionChanged playerId = \(String(describing: playerId!))")
                self.userDefault.setPlayerID(playerId!)
                if userDefault.getToken() != nil && userDefault.getPlayerID() != nil{
                    registerForPushNotification(playedId: userDefault.getPlayerID()!)
                }
            }
            else
            {
                self.userDefault.setPlayerID("D4CCA271-A6D1-4E68-BFE9-6AFF67B3D486")
                if userDefault.getToken() != nil && userDefault.getPlayerID() != nil{
                    registerForPushNotification(playedId: userDefault.getPlayerID()!)
                }
            }
        }
    }
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        if stateChanges.from.status == OSNotificationPermission.notDetermined || stateChanges.from.status == OSNotificationPermission.denied{
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let playerID = status.subscriptionStatus.userId
                if playerID != nil{
                    print("got playerID")
                    self.userDefault.setPlayerID(playerID!)
                }
                
                //if user changed status from disallow notification to allow notification and was logged in
                if stateChanges.from.status ==  OSNotificationPermission.denied && stateChanges.to.status ==  OSNotificationPermission.authorized {
                    if userDefault.getToken() != nil && userDefault.getPlayerID() != nil{
                        registerForPushNotification(playedId: userDefault.getPlayerID()!)
                    }
                }
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        
        if stateChanges.to.status == OSNotificationPermission.authorized{
            self.isNotificationAllowed = true
        }else{
            self.isNotificationAllowed = false
        }
    }
    
    func registerForPushNotification(playedId : String){
        if userDefault.getToken() != nil{
            DispatchQueue.main.async(execute: {
                let userRepository = Injection.provideUserRepository()
                userRepository.registerForPushNotification(playedId : playedId, token: nil, completionHandler: { (result, error) in
                    if error == NetworkUserRepository.ErrorType.none{
                        print("user registered successfully for push notification")
                    }
                })
            })
        }
    }
    
    
    //ENTER THIS FUNCTION WHEN APP recieve push notification FOREGROUND and background if content avaiable true
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        let notificationInfo = userInfo as NSDictionary
        let custom = notificationInfo["custom"] as? NSDictionary
        if custom != nil{
            let a = custom!["a"] as? NSDictionary
            print("a : \(String(describing: a))")
            if a != nil{
                let userObject = a!["user"] as? NSDictionary
                if userObject != nil{
                    parseUserData(userObject: userObject!)
                }
                
                let balance = a!["balance"] as? String
                if balance != nil{
                    let user = userDefault.getUserData()
                    user.balance = Double(balance!)
                    self.userDefault.setUserData(userData: user)
                    
                }
                
                let orderObject = a!["order"] as? NSDictionary
                var orderID = 0
                if orderObject != nil{
                    orderID = parseOrderData(orderObject: orderObject!)
                    handleOrderDataUpdate(orderID: orderID)
                    handleCompletedOrder(orderID: orderID, orderObject: orderObject!, notificationObject: a!)
                }
                
                //read it only when user recieve push notification 
               let hasNotifcation = a!["has_app_notif"] as? Bool
                if hasNotifcation != nil{
                    if hasNotifcation!{
                        self.userDefault.setNotificationUnread(true)
                    }
                }
               handleDataUpdate()
            }
        }
    }
    
    func parseUserData(userObject : NSDictionary){
        //save the user in user default to indicate any change in unseen count or has request and become delegate
        let user = userDefault.getUserData()
        if let gender = userObject["gender"] as? String{
            user.gender = gender
        }
        
        if let has_delegate_request = userObject["has_delegate_request"] as? Bool{
            user.has_delegate_request = has_delegate_request
        }
        
        if let id = userObject["id"] as? Int{
            user.id = id
        }
        
        if let is_delegate = userObject["is_delegate"] as? Bool{
            user.is_delegate = is_delegate
        }
        
        if let lang = userObject["lang"] as? String{
            user.lang = lang
        }
        
        if let mobile = userObject["mobile"] as? String{
            user.mobile = mobile
        }
        
        if let name = userObject["name"] as? String{
            user.name = name
        }
        
        if let balance = userObject["balance"] as? Double{
            user.balance = balance
        }
        
        if let unseen_notifications_count = userObject["unseen_notifications_count"] as? Int{
            user.unseen_notifications_count = unseen_notifications_count
        }
        
        if let notifications_enabled = userObject["notifications_enabled"] as? Bool{
            user.notifications_enabled = notifications_enabled
        }
        
        self.userDefault.setUserData(userData: user)
    }
    
    func parseOrderData(orderObject : NSDictionary) -> Int{
        var id = 0
        if let orderID = orderObject["id"] as? Int{
            id = orderID
        }
        return id
    }
    
    func handleDataUpdate(){
        if let tabBarView = self.topMostController() as?  UserTabBar {
            print("It's an AnyObject: UserTabBar")
            tabBarView.checkunreadNotifications()
            if tabBarView.selectedIndex == 0{
                print("It's an AnyObject: NotificationListVC")
                let nav = tabBarView.viewControllers![0] as! UINavigationController
                let vc = nav.topViewController as! NotificationListVC
                vc.intializeNotificationList()
            }else if tabBarView.selectedIndex == 3 {
                print("It's an AnyObject: MyAccountVC")
                let nav = tabBarView.viewControllers![3] as! UINavigationController
                let vc = nav.topViewController as! MyAccountVC
                vc.setUserData()
            }
            
            let nav = tabBarView.viewControllers![1] as! UINavigationController
            let vc = nav.topViewController as! MyOrdersVC
            if (vc.isViewLoaded) {
                vc.userRecievesNotification()
            }
        }else  if let nav = self.topMostController() as?  UINavigationController{
            if let currentOrdersVC = nav.topViewController as? CurrentOrdersList{
                if (currentOrdersVC.isViewLoaded) {
                    currentOrdersVC.resetData()
                }
            }
            
            if let balanceDetailsVC = nav.topViewController as? BalanceDetailsVC{
                if (balanceDetailsVC.isViewLoaded) {
                    balanceDetailsVC.customizeWalletView()
                    balanceDetailsVC.resetData()
                }
            }
            
            if let balanceOptionsVC = nav.topViewController as? BalanceOptionsVC{
                if (balanceOptionsVC.isViewLoaded) {
                    balanceOptionsVC.setMinusBalance()
                }
            }
            
            self.myOrdersNeedUpdate = true
            self.currentOrdersNeedUpdate = true
        }else{
            self.myOrdersNeedUpdate = true
            self.currentOrdersNeedUpdate = true
        }
        
    }
    
    func handleOrderDataUpdate(orderID: Int){
        if let navView = self.topMostController() as?  UINavigationController {
            if let orderVC = navView.topViewController as?  UserOrderDetailsVC {
                if orderVC.orderID == orderID{
                        orderVC.reloadOrderData()
                }
            }else if let orderVC = navView.topViewController as?  DelegateOrderDetailsVC {
                if orderVC.orderID == orderID{
                    orderVC.reloadOrderData()
                }
            }
        }
    }
    
    func handleCompletedOrder(orderID: Int, orderObject : NSDictionary,notificationObject : NSDictionary){
        if let status = orderObject["status"] as? String{
            //refresh chatvc distance
            if let navView = self.topMostController() as?  UINavigationController {
                if let chatVC = navView.topViewController as?  ChatVC {
                    if chatVC.order.id != nil{
                        if chatVC.order.id == orderID{
                            chatVC.changeOrderStatus(status: status)
                        }
                    }
                }
            }
            
            if status == "delivered" || status == "cancelled"{
                if let navView = self.topMostController() as?  UINavigationController {
                    if (navView.topViewController as?  ChatVC) != nil {
//                        let storyboard = UIStoryboard(name: "UserOrderDetails", bundle: nil)
//                        let navViewController = storyboard.instantiateInitialViewController() as! UINavigationController
//                        let orderVC = navViewController.topViewController as! UserOrderDetailsVC
//                        orderVC.orderID = orderID
//                        orderVC.isNeedToBackToOrders = true
//                        window?.rootViewController = navViewController
//                        window?.makeKeyAndVisible()
                        handleLinkToCompletedOrder(orderID: orderID, notificationObject: notificationObject)
                    }
                }
            }
        }
    }
    
    func handleLinkToCompletedOrder(orderID: Int, notificationObject : NSDictionary){
    
        let linkScreen = notificationObject["link_to"] as? String
        if linkScreen != nil && userDefault.getToken() != nil{
            if linkScreen == "delegate_order_details"{
                let storyboard = UIStoryboard(name: "DelegateOrderDetails", bundle: nil)
                let navViewController = storyboard.instantiateInitialViewController() as! UINavigationController
                let orderVC = navViewController.topViewController as! DelegateOrderDetailsVC
                orderVC.orderID = orderID
                orderVC.isFromDeliverOrder = true
                window?.rootViewController = navViewController
                window?.makeKeyAndVisible()
            }else if linkScreen == "order_details"{
                let storyboard = UIStoryboard(name: "UserOrderDetails", bundle: nil)
                let navViewController = storyboard.instantiateInitialViewController() as! UINavigationController
                let orderVC = navViewController.topViewController as! UserOrderDetailsVC
                orderVC.orderID = orderID
                orderVC.isNeedToBackToOrders = true
                window?.rootViewController = navViewController
                window?.makeKeyAndVisible()
            }
        }
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    
  
    // Called when user click on notification froground , background , terminated
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        let notificationInfo = userInfo as NSDictionary
        let custom = notificationInfo["custom"] as? NSDictionary
        if custom != nil{
            if let url = custom!["u"] as? String{
                UIApplication.tryURL(urls: [url])
            }
            let a = custom!["a"] as? NSDictionary
            print("a : \(String(describing: a))")
            if a != nil{
                let userObject = a!["user"] as? NSDictionary
                if userObject != nil{
                    parseUserData(userObject: userObject!)
                }
                
                let orderObject = a!["order"] as? NSDictionary
                var orderID = 0
                if orderObject != nil{
                    orderID = parseOrderData(orderObject: orderObject!)
                }
                
                let linkScreen = a!["link_to"] as? String
                if linkScreen != nil && userDefault.getToken() != nil{
                    if linkScreen == "orders"{
                        isFromNotifications = true
                        let storyboard = UIStoryboard(name: "UserTabBar", bundle: nil)
                        let destinationTabBar = storyboard.instantiateInitialViewController() as! UserTabBar
                        destinationTabBar.selectedIndex = 1
                        window?.rootViewController = destinationTabBar

                    }else if linkScreen == "account"{
                        isFromNotifications = true
                        let storyboard = UIStoryboard(name: "UserTabBar", bundle: nil)
                        let destinationTabBar = storyboard.instantiateInitialViewController() as! UserTabBar
                        destinationTabBar.selectedIndex = 3
                        window?.rootViewController = destinationTabBar
                        
                    }else if linkScreen == "delegate_order_details"{
                        isFromNotifications = true
                        let storyboard = UIStoryboard(name: "DelegateOrderDetails", bundle: nil)
                        let destinationNav = storyboard.instantiateInitialViewController() as! UINavigationController
                        let destinationVC = destinationNav.topViewController as! DelegateOrderDetailsVC
                        destinationVC.orderID = orderID
                        destinationVC.isFromPushNotifications = true
                        window?.rootViewController = destinationNav
                    }else if linkScreen == "order_details"{
                        isFromNotifications = true
                        let storyboard = UIStoryboard(name: "UserOrderDetails", bundle: nil)
                        let destinationNav = storyboard.instantiateInitialViewController() as! UINavigationController
                        let destinationVC = destinationNav.topViewController as! UserOrderDetailsVC
                        destinationVC.orderID = orderID
                        destinationVC.isFromPushNotifications = true
                        window?.rootViewController = destinationNav
                    }else if linkScreen == "delegate_orders"{
                        isFromNotifications = true
                        let storyboard = UIStoryboard(name: "UserTabBar", bundle: nil)
                        let destinationTabBar = storyboard.instantiateInitialViewController() as! UserTabBar
                        destinationTabBar.selectedIndex = 1
                        if destinationTabBar.viewControllers != nil{
                            if (destinationTabBar.viewControllers?.count)! > 2{
                                let nav = destinationTabBar.viewControllers![1] as! UINavigationController
                                let vc = nav.topViewController as! MyOrdersVC
                                vc.isUser = false
                                window?.rootViewController = destinationTabBar
                            }
                        }
                    }
                }
            }
        }
    }
    
   //to fetch user data as we don't read notification in background
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        if userDefault.getToken() != nil{
            print("call network")
            DispatchQueue.main.async(execute: {
                let userRepository = Injection.provideUserRepository()
                userRepository.getProfile(completionHandler: { (result, error) in
                    if error == NetworkUserRepository.ErrorType.none{
                        print("got user profile")
                        if result != nil{
                            if result!.data != nil{
                                self.userDefault.setUserData(userData: (result?.data!)!)
                            }
                        }
                    }
                })
            })
        }
    }
    
 
    
}

extension AppDelegate {
    
    
    func initLanguage() {
 
        let languages = userDefault.getLanguage()!
        if(languages.contains("ar")) {
            isRTL = true
        } else {
            isRTL = false
        }
//        DropDown.startListeningToKeyboard()
        
        if(isRTL) {
            UIView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UINavigationBar.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UISearchBar.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
//            SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelRight
            UITextView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UITextField.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
//            ImageSlideshow.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            
//            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UILabel.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UISearchBar.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UIScrollView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            UICollectionView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
            CosmosView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UINavigationBar.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UISearchBar.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
//            SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelLeft
            UITextView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UITextField.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
//            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UILabel.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UISearchBar.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UIScrollView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            UICollectionView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            CosmosView.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight

        }
        //UIApplication.shared.statusBarStyle = .lightContent
        
        
//        SideMenuController.preferences.drawing.sidePanelWidth = 250
//        SideMenuController.preferences.drawing.centerPanelShadow = true
//        SideMenuController.preferences.animating.transitionAnimator = nil
//        SideMenuController.preferences.interaction.swipingEnabled = false
        
    }
    
    func hintRTL(textfild : UITextField)  {
        if isRTL {
            myDirection = NSTextAlignment.right
        }else{
            myDirection = NSTextAlignment.left
        }
        textfild.textAlignment = ((textfild.text?.count)!==0) ? myDirection! : NSTextAlignment.natural;
    }
    
    func setLangauge(_ language: String) {
        userDefault.setLanguage(language)
        initLanguage()
    }
    
    func loadAndSetRootWindow() {
    
        if !isFromNotifications{
            if (userDefault.getToken() == nil) {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
            }else{
                let storyboard = UIStoryboard(name: "UserTabBar", bundle: nil)
                
                let viewController = storyboard.instantiateInitialViewController() as! UserTabBar
                viewController.selectedIndex = 2
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
                
            }
        }
    }
}

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
}
