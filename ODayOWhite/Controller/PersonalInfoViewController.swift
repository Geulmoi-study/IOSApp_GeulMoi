//
//  LikeViewViewController.swift
//  ODayOWhite
//
//  Created by dev.geeyong on 2021/01/13.
//

import UIKit
import Firebase
import MessageUI
import SafariServices

class PersonalInfoViewController: UIViewController  {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var curruntEmail: UILabel!
    @IBOutlet weak var curruntNickname: UILabel!
    @IBOutlet weak var saveTextButton: UIButton!
    @IBOutlet weak var writeTextButton: UIButton!
    @IBOutlet weak var topView: UIView!
    
    private let db = Firestore.firestore()
    private var ary:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationView()
        showName()
    }
    
    //MARK: Helper
    func showName() {
        if let currentEmail = Auth.auth().currentUser?.email {
            curruntEmail.text = currentEmail
            DispatchQueue.global().async {
                if let currentEmail = Auth.auth().currentUser?.email{
                    self.db.collection("usersData")
                        .whereField("email", isEqualTo: currentEmail)
                        .getDocuments(){(querySnapshot, err) in
                            if let err = err {
                                print(err)
                            } else {
                                if let doc = querySnapshot!.documents.first{
                                    let data = doc.data()
                                    guard let dataText = data["nickname"] as? String else {
                                        return
                                    }
                                    self.curruntNickname.text = dataText
                                } else {
                                }
                            }
                        }
                }
            }
        }
    }
    
    func configurationView() {
        topView.layer.cornerRadius = 10
        saveTextButton.layer.cornerRadius = 10
        writeTextButton.layer.cornerRadius = 10
        writeTextButton.clipsToBounds = true
        saveTextButton.clipsToBounds = true
        topView.clipsToBounds = true
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage() //remove pesky 1 pixel line
    }
    
    func showMailComposer(){
        guard  MFMailComposeViewController.canSendMail() else {
            self.view.makeToast("연결된 mail이 없습니다 아이폰 기본 mail 어플을 확인해주세요")
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["dev.geeyong@gmail.com"])
        composer.setSubject("신고 / 문의")
        composer.setMessageBody("", isHTML: false)
        
        present(composer, animated: true)
    }
    
    
    //MARK: Action
    @IBAction func contactButtonAction(_ sender: UIButton) {
        showMailComposer()
    }
    
    @IBAction func touchUpLogoutButton(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        sender.transform = CGAffineTransform.identity
                       },
                       completion: { Void in()  }
        )
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        UserDefaults.standard.removeObject(forKey: "id")
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

