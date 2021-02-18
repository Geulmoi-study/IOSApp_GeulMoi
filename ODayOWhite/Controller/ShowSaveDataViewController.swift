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
       configure()
        data()
    }
    
    //MARK: Helper
    func data() {
        API.shared.MessageData() { doc in
            let data = doc.data()
            self.ary = data["likemessages"] as? Array<String>
            self.tableView.reloadData()
        }
    }
    
    func configure() {
        tableView.rowHeight = 80.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LikeMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "LikeMessageCell")
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
        
        switch orientation {
        case .right:
             //API class 에서 데이터 가져오기 
            let deleteAction = SwipeAction(style: .default, title: nil, handler: {
                action, indexPath in
                API.shared.MessageData { (doc) in
                    doc.reference.updateData(["likemessages":FieldValue.arrayRemove([self.ary![indexPath.row]])])
                    
                    self.view.makeToast("삭제완료")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.navigationController?.popViewController(animated: true)
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

