//
//  SplashVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/9/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import Spring
import Lottie

class SplashVC: UIViewController{
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let userDefault = UserDefault()
    
    private var boatAnimation: LOTAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAnimation()
        beginAnimation()
//        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.startApp), userInfo: nil, repeats: false);
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func initAnimation(){
//        boatAnimation = LOTAnimationView(name: "data_247")
        boatAnimation = LOTAnimationView(name: "data")
        // Set view to full screen, aspectFill
        boatAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        boatAnimation!.contentMode = .scaleAspectFill
        boatAnimation!.frame = self.view.frame
        
    }
    
    @objc func beginAnimation() {
        // Add the Animation
        view.addSubview(boatAnimation!)
        self.boatAnimation?.play()
        print("splash: \( Double((self.boatAnimation?.animationDuration)!))")
        Timer.scheduledTimer(timeInterval: Double((self.boatAnimation?.animationDuration)!), target: self, selector: #selector(self.startApp), userInfo: nil, repeats: false);
        //self.appDelegate?.loadAndSetRootWindow()
        
    }
    
    @objc func startApp() {
//       performSegue(withIdentifier: "toLogin", sender: self)
        if userDefault.isFirstLaunch() != nil{
            if !userDefault.isFirstLaunch()!{
                performSegue(withIdentifier: "toHowToUse", sender: self)
            }else{
                // not first launch
                if userDefault.getToken() != nil{
                    if userDefault.getUserData().name == nil{
                        // no full name
                        performSegue(withIdentifier: "toEditProfile", sender: self)
                    }else if userDefault.getUserData().name == ""{
                        // no full name
                        performSegue(withIdentifier: "toEditProfile", sender: self)
                    }else{
                        appDelegate?.loadAndSetRootWindow()
                    }
                }else{
                    appDelegate?.loadAndSetRootWindow()
                }
            }
        }else{
            // is first launch == nil so first launch
            performSegue(withIdentifier: "toHowToUse", sender: self)
        }
       
    }
}
