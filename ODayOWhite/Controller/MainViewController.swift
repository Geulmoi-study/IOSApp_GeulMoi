//
//  MainViewController.swift
//  ODayOWhite
//
//  Created by dev.geeyong on 2021/01/12.
//

import UIKit
//import SwipeableTabBarController
import Firebase
import SwipeCellKit
import Toast_Swift
import Kingfisher
import MessageUI



class MainViewController: UIViewController {
    
    @IBOutlet var bestMessage: UILabel!
    @IBOutlet var bestNickname: UILabel!
    @IBOutlet var bestLike: UILabel!
    @IBOutlet var bestImageView: UIImageView!
    
    
    var commonImageURL = ""
    
    
    var url: URL?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var messages: [Message] = []
    var testArray: [Feed] = []
    
    
    var block: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let blockEmail = UserDefaults.standard.string(forKey: "email"){
            block = blockEmail
        }
        print("메인페이지 viewDidLoad")
        self.loadBestMessage()
        self.loadMessages()
        
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.rowHeight = 200
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadMessages()
    }
    
    private func loadBestMessage(){
        db.collection("admin")
            .addSnapshotListener{(querySnapshot, error) in
                if let e = error{
                    print(e,"loadMessages error")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            self.bestMessage.text = data["message"] as? String //여기서는 text가 String?을 받기 때문에 as?로 한 것이다.
                            self.bestNickname.text = data["nickname"] as? String
                            self.bestLike.text = data["like"] as? String
                            
                            let url = URL(string: data["imageURL"] as? String ?? "") //따로 default 처리해 놓으신게 있나?
                            /*
                             1. optional에 대해 찾아봐야 함.
                             2. optional binding과 optional chaining의 차이는?
                             3. type casting. Any와 AnyObject에서의 타입 캐스팅은 어떻게 해주어야 하는 것인가?
                             4. ?? 와 같은 친구는 언제 사용? 지양하는 것이 좋은가?
                             */
                            
                            let urlData = try? Data(contentsOf: url!)
                            if urlData != nil{
                                self.bestImageView.image = UIImage(data: urlData!)
                                
                            }else{
                                self.bestImageView.image = UIImage(named: "38")
                            }
                            
                            self.url = URL(string: data["commonImage"] as! String)
                            let testUrl = try? Data(contentsOf: self.url!)
                            if testUrl == nil{
                                self.url = URL(string: "http://drive.google.com/uc?export=view&id=1lN6TfLHtLOQ5yY2BG3B7gnRw4E6vFiS9")
                            }
                            
                            
                        }
                    }
                }
            }
        
        
    }
    
    private func loadMessages(){
        db.collection("users")
            .order(by: "date")
            .addSnapshotListener{(querySnapshot, error) in
                self.messages = []
                if let e = error{
                    print(e,"loadMessages error")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            
                            if let messageSender = data["nickName"] as? String, let messageBody = data["mesagee"] as? String, let messageEmail = data["email"] as? String, let likeNum = data["likeNum"] as? Int, let blockcount = data["block"] as? Int{
                                
                                //신고를 3번 이상 당하면 없애는 건가 보구만.
                                if  blockcount >= 3{
                                    doc.reference.delete()
                                }
                                
                                //block 당한 글이 아니라면 보여지는 것이고.
                                //대체 TF가 무엇이지?
                                if messageEmail != self.block{
                                    let newMessage = Message(sender: messageEmail, body: messageBody, name: messageSender, likeNum: likeNum)
                                    self.messages.append(newMessage)
                                    let test = Feed(likeNum: likeNum, isFavorite: false)
                                    let test2 = Feed(likeNum: 18, isFavorite: false)
                                    if (K.TF == true){
                                        self.testArray.insert(test2, at: 0)
                                        K.TF = false
                                    }
                                    
                                    self.testArray.append(test)
                                }
                                
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    
                                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                                    
                                }
                                
                                
                                
                            }
                        }
                    }
                }
            }
    }
}
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        cell.delegate = self
        //        if self.testArray.count > 0 {
        //            cell.messageTextLabel.text = testArray[indexPath.row].content
        //        }
        cell.messageTextLabel.text = message.body
        cell.messageSenderLabel.text = message.name
        cell.messageCountLike.text = "\(message.likeNum)"
        cell.backgroundImageView.kf.setImage(with: url)
        
        
        
        return cell
    }
    
}
extension MainViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}
//MARK: - swipetable
extension MainViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        //여기서 굳이 형변환을 시켜준 이유는? 이미 배열 내부에 [Message]라는 것이 보여져 있는 상황인데.
        let message = messages[indexPath.row] as Message
        let dataItem = testArray[indexPath.row] as Feed
        
        //cell을 바인딩 시켜주지 않은 이유는? 사실 cell의 경우 굳이 필요하지는 않다만, 혹 모르기에
        let cell = tableView.cellForRow(at: indexPath) as! MessageCell
        
        switch orientation {
        
        case .left:
            let thumbsUpAction = SwipeAction(style: .default, title: nil, handler: {
                action, indexPath in
                
                
                
                let activityVC = UIActivityViewController(activityItems: [self.messages[indexPath.row].body], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
                tableView.reloadData()
            })
            
            thumbsUpAction.title = "공유하기"
            thumbsUpAction.image = UIImage(systemName: "square.and.arrow.up")
            thumbsUpAction.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            
            let thumbsUpAction2 = SwipeAction(style: .destructive, title: nil, handler: {
                action, indexPath in
                
                //                print(self.messages[indexPath.row])
                
                
                guard  MFMailComposeViewController.canSendMail() else {
                    self.view.makeToast("연결된 mail이 없습니다 아이폰 기본 mail 어플을 확인해주세요")
                    return
                }
                self.db.collection("users").whereField("email", isEqualTo: self.messages[indexPath.row].sender).getDocuments(){(querySnapshot, err) in
                    if let err = err {
                        print(err)
                    }else{
                        
                        let doc = querySnapshot!.documents.first
                        //doc?.reference.delete()
                        if let currentblock = doc?.data()["block"]{
                            doc?.reference.updateData(["block": currentblock as! Int + 1])
                            let composer = MFMailComposeViewController()
                            composer.mailComposeDelegate = self
                            composer.setToRecipients(["dev.geeyong@gmail.com"])
                            composer.setSubject("신고하기")
                            composer.setMessageBody("신고내용 : \(self.messages[indexPath.row].body) 닉네임 : \(self.messages[indexPath.row].sender)", isHTML: false)
                            UserDefaults.standard.set(self.messages[indexPath.row].sender, forKey: "email")
                            self.block = self.messages[indexPath.row].sender
                            self.present(composer, animated: true)
                            self.messages.remove(at: indexPath.row)
                            tableView.reloadData()
                        }
                        
                    }
                    
                    
                    
                }
                
            })
            
            thumbsUpAction2.title = "신고하기"
            thumbsUpAction2.image = UIImage(systemName: "exclamationmark.bubble")
            thumbsUpAction2.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
            return [thumbsUpAction2, thumbsUpAction]
            
            
        case .right:
            
            let thumbsUpAction = SwipeAction(style: .default, title: nil, handler: {
                action, indexPath in
                
                
                let updateedStatus = !dataItem.isFavorite
                dataItem.isFavorite = updateedStatus
                let body = self.messages[indexPath.row].body
                cell.hideSwipe(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    // 현재 스와이프 한 애만 리로드 하기
                    tableView.reloadRows(at: [indexPath], with: .none)
                })
                
                self.db.collection("users").whereField("mesagee", isEqualTo: body).getDocuments(){(querySnapshot, err) in
                    if let err = err {
                        print(err)
                    }else{
                        
                        let doc = querySnapshot!.documents.first
                        //doc?.reference.delete()
                        
                        //옵셔널 바인딩 처리할때 부터 as?로 다운 캐스팅을 해주면 굳이 내부에서 다시 캐스팅 해줄 필요가 없음.
                        if let likenum = doc?.data()["likeNum"] as? Int {
                            
                            if dataItem.isFavorite == true{
                                
                                doc?.reference.updateData([
                                    
                                    "likeNum": likenum + 1,
                                    
                                ])
                                self.view.makeToast("좋아요")
                                //tableView.reloadRows(at: [indexPath], with: .fade)
                            }else{
                                
                                doc?.reference.updateData([
                                    
                                    "likeNum": likenum - 1,
                                    
                                ])
                                self.view.makeToast("좋아요 취소")
                                //tableView.reloadRows(at: [indexPath], with: .fade)
                            }
                        }
                        
                    }
                }
            })
            
            
            //            if message.TF == false{
            
            thumbsUpAction.title = dataItem.isFavorite ? "좋아요 취소" : "좋아요"
            thumbsUpAction.image =  UIImage(systemName:dataItem.isFavorite ? "hand.thumbsdown.fill" : "hand.thumbsup.fill")
            thumbsUpAction.backgroundColor = dataItem.isFavorite ?  #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) : #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            
            
            
            //            }else{
            //                thumbsUpAction.title = "좋아요 취소"
            //                thumbsUpAction.image = UIImage(systemName: "hand.thumbsdown.fill")
            //                thumbsUpAction.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            //
            //            }
            //MARK: - 저장하기 스와이프
            let saveAction2 = SwipeAction(style: .default, title: nil, handler: {
                action, indexPath in
                
                DispatchQueue.main.async {
                    if let currentEmail = Auth.auth().currentUser?.email{
                        self.db.collection("usersData")
                            .whereField("email", isEqualTo: currentEmail)
                            .getDocuments(){(querySnapshot, err) in
                                if let err = err {
                                    print(err)
                                }else{
                                    
                                    if let doc = querySnapshot!.documents.first{
                                        doc.reference.updateData(["likemessages":FieldValue.arrayUnion([message.body])])
                                        self.view.makeToast("저장완료")
                                        tableView.reloadRows(at: [indexPath], with: .fade)
                                    }else{
                                        self.view.makeToast("fail")
                                        
                                    }
                                    
                                }
                            }
                    }
                }
                
            })
            saveAction2.title = "저장하기"
            saveAction2.image = UIImage(systemName: "square.and.arrow.down.fill")
            saveAction2.backgroundColor = #colorLiteral(red: 0.03715451062, green: 0.4638677239, blue: 0.9536394477, alpha: 1)
            return [saveAction2, thumbsUpAction]
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        
        return options
    }
}
