//
//  APIURLs.swift
//  TwentyfourSeven
//
//  Created by Salma Abd Elazim on 11/26/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import Foundation

// ********************* TO CREATE PRODUCTION VERSION ********************
// 1- CHANGE APP KEYS TO PRODUCTION
// 2- EDIT SCHEME TO RELEASE
// 3- CHANGE APIURLS TO PROD
// 4- CHANGE APP VERSION

// ********************* TO CREATE STAGE (CLIENT) VERSION ********************
// 1- CHANGE APP KEYS TO DEVELOPMENT
// 2- EDIT SCHEME TO DEBUG
// 3- CHANGE APIURLS TO STAGE
// 4- CHANGE APP VERSION

class APIURLs {
    
 //  static var MAIN_URL = "https://247dev.objectsdev.com/"     //dev
 //   static var MAIN_URL = "https://247test.objectsdev.com/"    //test
//    static var MAIN_URL = "https://247.objectsdev.com/"           //stage (client)
    static var MAIN_URL = "https://app.24-7-delivery.com/"        //production (store)
    

   // static var DATABASE_TABEL = "dev"                         //dev
  //  static var DATABASE_TABEL = "test"                        //test
//    static var DATABASE_TABEL = "stage"                       //stage (client)
    static var DATABASE_TABEL = "prod"                         //production (store)

//    //Payment not used
//    static var payFortTest = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi" //test
    var payFortURL = "https://paymentservices.payfort.com/FortAPI/paymentApi" //prod
//    static var payFortEnvirnmnet = KPayFortEnviromentSandBox     //Test
 //var payFortEnvirnmnet = KPayFortEnviromentProduction  //Prod

    static let SOCIAL_LOGIN = "login/social"
    static let REQUEST_CODE = "login/request-code"
    static let VERIFY_CODE = "login/verify"
    static let UPDATE_REQUEST_CODE = "profile/mobile/request-code"
    static let UPDATE_VERIFY_CODE = "profile/mobile/verify"
    static let PROFILE = "profile"
    static let LANGUAGE = "lang"
    static let PAGES = "pages"
    static let REFRESH = "token/refresh"
    static let CONTACT_US = "page/contact-us"
    static let ADDRESSES = "addresses"
    static let HOW_TO_USE = "page/how-to-use"
    static let HOW_BECOME_A_DELGATE = "page/how-to-become-a-delegate"
    static let DELEGATE_IMAGE = "delegates/images"
    static let DELEGATE_REQUEST = "delegates/requests"
    static let CAR_DETAILS = "profile/delegate-details"
    static let NOTIFICATION_REGISTERATION = "profile/devices"
    static let NOTIFICATIONS = "profile/notifications"
    static let NOTIFICATIONS_READ = "profile/notifications/mark-as-read"
    static let CATEGORIES = "categories"
    static let REQUEST_ORDER = "orders"
    static let ORDER_RECORD = "orders/voicenotes"
    static let ORDER_IMAGE = "orders/images"
    static let CUSTOMER_ORDER_DETAILS = "profile/orders"
    static let DELEGATE_ORDER_DETAILS = "profile/delegate-orders"
    static let OFFERS = "offers"
    static let ACCEPT_OFFER = "accept"
    static let CANCEL_OFFER = "cancel"
    static let REJECT_OFFER = "reject"
    static let REFRESH_DELEGATES = "research-delegates"
    static let START_RIDE = "start"
    static let PICK_ITEM = "pick-item"
    static let COMPLETE_RIDE = "complete"
    static let RATE = "ratings"
    static let CHAT_IMAGES = "chat/images"
    static let BLOCKED_AREAS = "settings"
    static let BANK_ACCOUNTS = "bank-accounts"
    static let USERS = "users"
    static let DELEGATE_DETAILS = "delegate-details"
    static let REVIEWS = "reviews"
    static let BANK_TRANSFER = "bank-transfer-requests"
    static let COMPLAINTS = "complaints"
    static let GET_TRANSACTIONS = "wallet/transactions"
    static let DELEGATE_WALLET = "wallet/details"
    static let DEVICES = "devices"
    static let CACELLATION_REASONS = "settings/order-cancel-reasons"
    static let DELEGATE_ORDERS = "delegate-orders"
    static let IGNORE_ORDER = "ignore"
    static let PRAYER_TIMES = "settings/prayer-times"
    static let VALIDATE_COUPON = "orders/validate-coupon"

    //my orders
    static let REQUESTS_ACTIVATION = "profile/activity-status"
    static let USER_CURRENT_ORDERS = "profile/orders/current"
    static let USER_PAST_ORDERS = "profile/orders/history"
    static let DELEGATE_CURRENT_ORDERS = "profile/delegate-orders/current"
    static let DELEGATE_PAST_ORDERS = "profile/delegate-orders/history"
    
    static let STORES_IMAGES = "images/stores/branches/"
    static let PAYMENT_REGISTER = "payment-cards/pay/request"

    
}
