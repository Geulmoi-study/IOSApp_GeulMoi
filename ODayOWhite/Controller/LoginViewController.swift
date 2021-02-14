//
//  LoginViewController.swift
//  ODayOWhite
//
//  Created by dev.geeyong on 2021/01/12.
//

import UIKit
import Firebase
import TweeTextField

class LoginViewController: UIViewController {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("첫화면 viewDidLoad")
        checkDefaultUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if LoginCoreClass.shared.isNewUser() {
            guard let vc = storyboard?.instantiateViewController(identifier: "welcome2") as? GuideViewController else {
                return
            }
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    //MARK: Helper
    func checkDefaultUser() {
        if let userID = UserDefaults.standard.string(forKey: "id") {
            self.performSegue(withIdentifier: SAGUE_ID.LOGIN_TO_MAIN, sender: self)
        }
    }
    
    // MARK: Action
    @IBAction func pressLoginButton(_ sender: UIButton) {
        if let email = idTextField.text , let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    self.view.makeToast("맞지 않는 메일 주소(비밀번호)입니다. 다시 입력해 주세요.")
                } else {
                    UserDefaults.standard.set(email, forKey: "id")
                    print("저장")
                    self.performSegue(withIdentifier: SAGUE_ID.LOGIN_TO_MAIN, sender: self)
                }
            }
        }
    }
}
