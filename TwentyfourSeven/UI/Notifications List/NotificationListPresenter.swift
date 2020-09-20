//
//  NotificationListPresenter.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 1/9/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit

class NotificationListPresenter : Presenter{
    
    var view : NotificationListView?
    var userRepository: UserRepository!
    var userDefault = UserDefault()
    var page = 1
    var limit = 10
    var notifications = [Notification]()
    
    init (repository: UserRepository) {
        userRepository = repository
    }
    
    func setView(view: NotificationListView) {
        weak var weakView = view
        self.view = weakView
    }
    
    func getUserNotifications(){
        if page == 1{
            self.view?.showloading()
        }
        self.userRepository.getUserNotification(page: self.page, limit: self.limit) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                if( result?.data!.notifications?.count == 0 && self.notifications.count == 0) {
                    self.view?.showNoData()
                } else if (self.notifications.count > 0 && result?.data!.notifications?.count == 0  ) {
                    self.view?.stopInfinitScroll()
                }else {
                    self.notifications.append(contentsOf: result!.data!.notifications!)
                    self.page = self.page+1
                    self.view?.setNotifications(notifications: self.notifications, unseenMsgsCount: (result?.data?.unseen_count!)!)
                }
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkUserRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }
    }
    
    func maskNotificationsAsSeen(){
        //self.view?.showloading()
        self.userRepository.markNotificationAsSeen { (result, error) in
            //self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.markNotificationSeenSuccessfully()
            }
        }

    }
    
    func changeNotificationStatus(status : Bool){
        self.view?.showloading()
        self.userRepository.changeNotificationStatus(status: status) { (result, error) in
            self.view?.hideLoading()
            if error == NetworkUserRepository.ErrorType.none{
                self.view?.changeNotificationStatusSuccessfully(userData: (result?.data)!)
            }else if error == NetworkUserRepository.ErrorType.invalidValue{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.auth{
//                self.userDefault.removeSession()
                self.userRepository.generalRefreshToken()
            }else if error == NetworkUserRepository.ErrorType.suspended{
//                self.userDefault.removeSession()
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.controlError{
                if result?.error != nil{
                    if result?.error?.defaultError != nil{
                        self.view?.showSusspendedMsg(msg: (result?.error?.defaultError)!)
                    }
                }
            }else if error == NetworkUserRepository.ErrorType.serverError{
                self.view?.showGeneralError()
            }else if error == NetworkUserRepository.ErrorType.generalError{
                self.view?.showGeneralError()
            }else{
                self.view?.showNetworkError()
            }
        }

    }
    
    func resetData(){
        self.page = 1
        self.notifications.removeAll()
    }
    
    func didLoad() {
        
    }
    
    func didAppear() {
        
    }
    
}

protocol NotificationListView : class {
    
    func showloading()
    func hideLoading()
    func showNetworkError()
    func showGeneralError()
    func showSusspendedMsg(msg : String)
    func setNotifications(notifications : [Notification] , unseenMsgsCount : Int)
    func showNoData()
    func stopInfinitScroll()
    func changeNotificationStatusSuccessfully(userData : UserData)
    func markNotificationSeenSuccessfully()
}
