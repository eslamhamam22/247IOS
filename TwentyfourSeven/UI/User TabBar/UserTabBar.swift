//
//  UserTabBar.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/9/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit

class UserTabBar: UITabBarController  , UITabBarControllerDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        setupTabBarUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkunreadNotifications()
    }
    
    func checkunreadNotifications(){
        //put red dot to notify uiser that there are unsenn notifications
        if userDefault.hasNotificationUnread() ?? false{
            self.tabBar.items?[0].badgeValue = "●"
        }else if userDefault.getUserData().unseen_notifications_count != nil{
            if userDefault.getUserData().unseen_notifications_count! != 0 {
                self.tabBar.items?[0].badgeValue = "●"
            }else{
                self.tabBar.items?[0].badgeValue = ""
            }
        }else{
            self.tabBar.items?[0].badgeValue = ""
        }
        
        self.tabBar.items?[0].badgeColor = .clear
        self.tabBar.items?[0].setBadgeTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.red], for: .normal)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTabBarUI(){
        self.tabBar.items?[0].title = "notifications_screen_title".localized()
        self.tabBar.items?[1].title = "ordersTab".localized()
        self.tabBar.items?[2].title = "storesTab".localized()
        self.tabBar.items?[3].title = "accountTab".localized()
        self.tabBar.items?[4].title = "settingsTab".localized()
        
        self.tabBar.items?[0].selectedImage = UIImage(named: "notifcation_nr_ic-1")
        self.tabBar.items?[0].image = UIImage(named: "notifcation_nr_ic")
        self.tabBar.items?[1].selectedImage = UIImage(named: "orders_ac_ic")
        self.tabBar.items?[1].image = UIImage(named: "orders_nr_ic")
        self.tabBar.items?[2].selectedImage = UIImage(named: "stores_ac_ic")
        self.tabBar.items?[2].image = UIImage(named: "stores_nr_ic")
        self.tabBar.items?[3].selectedImage = UIImage(named: "myaccount_ac_ic")
        self.tabBar.items?[3].image = UIImage(named: "myaccount_nr_ic")
        self.tabBar.items?[4].selectedImage = UIImage(named: "settings_ac_ic")
        self.tabBar.items?[4].image = UIImage(named: "settings_nr_ic")
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: Utils.customDefaultFont(11)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: Utils.customDefaultFont(11)], for: .selected)
        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = Colors.hexStringToUIColor(hex: "#6c727b")
        } else {
            //Fallback on earlier versions
            self.tabBar.items?[4].setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "#6c727b")], for: .normal)
            self.tabBar.items?[3].setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "#6c727b")], for: .normal)
            self.tabBar.items?[2].setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "#6c727b")], for: .normal)
            self.tabBar.items?[1].setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "#6c727b")], for: .normal)
            self.tabBar.items?[0].setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "#6c727b")], for: .normal)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[0] && userDefault.getToken() == nil{
            appDelegate.isFromNotifications = false
            appDelegate.loadAndSetRootWindow()
            return false
        }else  if viewController == tabBarController.viewControllers?[1] && userDefault.getToken() == nil{
            appDelegate.isFromNotifications = false
            appDelegate.loadAndSetRootWindow()
            return false
        }else  if viewController == tabBarController.viewControllers?[3] && userDefault.getToken() == nil{
            appDelegate.isFromNotifications = false
            appDelegate.loadAndSetRootWindow()
            return false
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("item \(String(describing: tabBar.items?.index(of: item)))")
    }
}

