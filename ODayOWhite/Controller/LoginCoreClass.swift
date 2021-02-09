//
//  LoginCoreClass.swift
//  ODayOWhite
//
//  Created by sangheon on 2021/02/09.
//

import UIKit

class LoginCoreClass {
    
    static let shared = LoginCoreClass()
    
    func isNewUser() -> Bool{
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    func setIsNotNewUser(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
