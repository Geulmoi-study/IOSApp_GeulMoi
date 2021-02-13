//
//  API.swift
//  ODayOWhite
//
//  Created by 김동준 on 2021/02/13.
//

import Foundation
import Firebase

//싱글톤 패턴을 통해 class의 객체가 한번만 생성될 것을 보장하여 메모리 과부화를 막아주고, 따라서 ViewController에서 각 함수들을 용이하게 사용할 수 있음.
class API {
    static let shared = API()
    
    let db = Firestore.firestore()
    
    //비동기 처리 후에 completion 블럭을 처리시켜서 가독성이 더 좋고, 꼭 tableView reload 뿐만이 아니라 다른 뷰들의 업로드를 시켜줄 수 있음.
    //completionHandler로 모두 처리 시킨 후에 아예 API 파일을 따로 만들어서 함수들을 정리해주는게 훨씬 편함.
    //앞으로 남은 것들을 completionHandler로 변경하여 API 파일로 따로 처리해주는 것이 ViewController가 heavy해 지지 않게 해주고, 더 자유롭게 사용할 수 있음
    
    //일단 ShowSaveDataViewController의 getMessageData만 옮겨봄
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
