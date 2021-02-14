//
//  WriteViewController.swift
//  ODayOWhite
//
//  Created by dev.geeyong on 2021/01/13.
//

import UIKit
import Firebase
import YPImagePicker
import TweeTextField
import ChameleonFramework

class WriteViewController: UIViewController {
    
    @IBOutlet var whiteView: UIView!
    
    
    @IBOutlet var captureView: UIView!
    @IBOutlet var testimagevieww: UIImageView!
    @IBOutlet var topView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var inputText: UILabel!
    @IBOutlet var senderNickName: UILabel!
    @IBOutlet var textField: UITextField!
    var photoImage: UIImage!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        textField.becomeFirstResponder()
        imageView.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 20
        submitButton.clipsToBounds = true
        leftButton.layer.cornerRadius = 20
        leftButton.clipsToBounds = true
        rightButton.layer.cornerRadius = 20
        rightButton.clipsToBounds = true
        imageView.clipsToBounds = true
        textField.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        submitButton.isEnabled = false
        textField.becomeFirstResponder()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        textField.text = ""
    }
    //글쓰기버튼
    @IBAction func pressButton(_ sender: UIButton) {
        
        
        if let inputMessaege = inputText.text{
            
            db.collection("users").addDocument(data: [
                "email" : K.email,
                "nickName" : K.nickName,
                "mesagee" : inputMessaege,
                "date" : 0 - Date().timeIntervalSince1970,
                "likeNum" : 0,
                "block" : 0
            ]){(error) in
                if let e = error {
                    print(e)
                }else{
                    
                    print( Auth.auth().currentUser?.email ?? "sucsee")
                }
            }
        }
        // K.TF.insert(true, at: 0)
        K.TF = true
        self.tabBarController?.selectedIndex = 0
        
        
        
        
    }
    
    @IBAction func textfieldChanged(_ sender: TweeAttributedTextField) {
        if let userInput = sender.text {
            if userInput.count == 0{
                sender.activeLineColor = #colorLiteral(red: 0.03715451062, green: 0.4638677239, blue: 0.9536394477, alpha: 1)
                sender.hideInfo(animated: true)
            }else if userInput.count < 6{
                sender.infoTextColor = .red
                sender.activeLineColor = .red
                sender.showInfo("6글자 이상 입력하세요!", animated: true)
            }else{
                sender.infoTextColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                sender.activeLineColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                sender.hideInfo(animated: true)
            }
            
        }
    }
    //MARK: - 이미지 변경하기 (카메라, 라이브러리)
    @IBAction func changeImage(_ sender: UIButton) {
        
        
        var config = YPImagePickerConfiguration()
        config.screens = [.photo , .library]
        config.targetImageSize = YPImageSize.cappedTo(size: 400)
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
                
                self.imageView.image = photo.image
                self.photoImage = photo.image
                self.imageView.layer.cornerRadius = 10
                self.imageView.clipsToBounds = true
                let colur = AverageColorFromImage(photo.image)
                self.inputText.textColor = ContrastColorOf(colur, returnFlat: true)
                self.senderNickName.textColor = ContrastColorOf(colur, returnFlat: true)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    //MARK: - 이미지 캡쳐 저장
    @IBAction func imagePicker(_ sender: UIButton){
        imageView.layer.cornerRadius = 0
        imageView.clipsToBounds = false
        let image = captureView.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        self.view.makeToast("사진을 저장했습니다.")
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
    }
    
}
extension WriteViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //참고 링크 : https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/FirestoreSettings#dispatchqueue
        //Firestore의 getDocuments 메소드는 기본적으로 mainQueue에서 모든 task를 수행함. (completion을 통해 모든 수행이 끝나고 따로 리턴하는 것을 보면 됨) -> 참고 링크 : https://firebase.googleblog.com/2018/07/swift-closures-and-firebase-handling.html
        //이미 이 자체가 비동기 프로그래밍을 하고 있음. 따라서 굳이 이 전체에 main.async를 걸어줄 필요가 없음.
        //더 정밀하게 말해보자면 이 함수 내부에서는 그냥 비동기 처리 자체가 필요가 없음.
        //getDocuments의 completion 블럭을 한번 보자면 비동기 처리되는 것이 아니라 전부 동기적으로 처리되어도 상관 없는 구조를 가지고 있기 때문.
        
        //Q) 왜 굳이 이 전체에 비동기 처리를 해준 것인가? 이 전체에 비동기 처리를 해주게 되면 잘못하면은 아래 진행되는 것들이 오류가 날 수도 있지 않나? getDocumets에서 값을 가져와서 할당해 주기 전에 아래 것이 먼저 실행되어 버리면 senderNickname.text에는 가져온 값이 들어가지 않을 수도 있는데? 흠.. 이유를 알고 싶다.
        
        if let currentEmail = Auth.auth().currentUser?.email{
            self.db.collection("usersData").whereField("email", isEqualTo: currentEmail).getDocuments(){(querySnapshot, err) in
                if let err = err {
                    print(err)
                }else{
                    for doc in querySnapshot!.documents{
                        let data = doc.data()
                        if let nickname = data["nickname"] as? String {
                            DispatchQueue.main.async {
                                self.senderNickName.text = nickname
                                K.nickName = nickname
                                K.email = currentEmail
                            }
                        }
                    }
                }
            }
        }
        senderNickName.text = K.nickName
        if textField.text! != ""{
            inputText.text = textField.text
        }
        if(textField.text!.count > 5){
            print(textField.text!.count)
            submitButton.isEnabled = true
        }
        else{
            submitButton.isEnabled = false
        }
        
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //여기도 위의 답변을 알고나면 똑같이 수정하면 될 듯
        DispatchQueue.main.async {
            if let currentEmail = Auth.auth().currentUser?.email{
                self.db.collection("usersData").whereField("email", isEqualTo: currentEmail).getDocuments(){(querySnapshot, err) in
                    if let err = err {
                        print(err)
                    }else{
                        for doc in querySnapshot!.documents{
                            let data = doc.data()
                            if let nickname = data["nickname"]{
                                self.senderNickName.text = nickname as? String
                                K.nickName = nickname as! String
                                K.email = currentEmail
                            }
                        }
                    }
                }
            }
        }
        senderNickName.text = K.nickName
        if textField.text! != ""{
            inputText.text = textField.text
            
        }
        if(textField.text!.count > 5){
            print(textField.text!.count)
            submitButton.isEnabled = true
        }else{
            submitButton.isEnabled = false
        }
        
        
        
    }
}
extension UIView {
    
    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.
    
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
