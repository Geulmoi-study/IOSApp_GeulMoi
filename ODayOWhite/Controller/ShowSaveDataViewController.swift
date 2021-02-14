//
//  ShowSaveDataViewController.swift
//  ODayOWhite
//
//  Created by dev.geeyong on 2021/01/18.
//

import UIKit
import Firebase
import SwipeCellKit

class ShowSaveDataViewController: UIViewController {
    let db = Firestore.firestore()
    //굳이 옵셔널로 처리해준 이유는?
    var ary:Array<String>? = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LikeMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "LikeMessageCell")
        
        API.shared.getMessageData() { data in
            self.ary = data["likemessages"] as? Array<String>
            self.tableView.reloadData()
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getMessageData() { [weak self] data in
            guard let weakSelf = self else {return}
            weakSelf.ary = data["likemessages"] as? Array<String>
            weakSelf.tableView.reloadData()
        }
        
    }
    
    func loadMessages(){
        DispatchQueue.main.async {
            if self.ary != nil{
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }else{
                print("loadMessage error")
            }}
    }
    
    //비동기 처리 후에 completion 블럭을 처리시켜서 가독성이 더 좋고, 꼭 tableView reload 뿐만이 아니라 다른 뷰들의 업로드를 시켜줄 수 있음.
    //completionHandler로 모두 처리 시킨 후에 아예 API 파일을 따로 만들어서 함수들을 정리해주는게 훨씬 편함.
    //앞으로 남은 것들을 completionHandler로 변경하여 API 파일로 따로 처리해주는 것이 ViewController가 heavy해 지지 않게 해주고, 더 자유롭게 사용할 수 있음
    func getMessageData(compeltionHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async {
            if let currentEmail = Auth.auth().currentUser?.email{
                self.db.collection("usersData")
                    .whereField("email", isEqualTo: currentEmail)
                    .getDocuments(){(querySnapshot, err) in
                        if let err = err {
                            print(err)
                        }else{
                            if let doc = querySnapshot!.documents.first{
                                let data = doc.data()
                                compeltionHandler(data)
                                
                            }else{
                                
                            }
                        }
                    }
            }
        }
    }
    
    
}
extension ShowSaveDataViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ary != nil{
            return ary!.count
        }
        else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeMessageCell", for: indexPath) as! LikeMessageTableViewCell
        cell.delegate = self
        if ary != nil {
            cell.likeMessage.text = ary![indexPath.row]
            
        }
        return cell
    }
    
    
}
extension ShowSaveDataViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeMessageCell", for: indexPath) as! LikeMessageTableViewCell
        
        switch orientation {
        
        case .right:
            
            let deleteAction = SwipeAction(style: .default, title: nil, handler: {
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
                                        
                                        doc.reference.updateData(["likemessages":FieldValue.arrayRemove([self.ary![indexPath.row]])])
                                        
                                        self.view.makeToast("삭제완료")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        
                                        
                                    }else{
                                        self.view.makeToast("fail")
                                        
                                    }
                                    
                                }
                            }
                    }
                }
            })
            
            deleteAction.title = "삭제하기"
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            
            return [deleteAction]
            
            
        case .left:
            let thumbsUpAction = SwipeAction(style: .default, title: nil, handler: {
                action, indexPath in
                
                
                
                let activityVC = UIActivityViewController(activityItems: [self.ary![indexPath.row]], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
                tableView.reloadData()
            })
            
            thumbsUpAction.title = "공유하기"
            thumbsUpAction.image = UIImage(systemName: "square.and.arrow.up")
            thumbsUpAction.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            
            
            
            return [thumbsUpAction]
        }
        
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        
        return options
    }
    
}
extension ShowSaveDataViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
        
    }
}
