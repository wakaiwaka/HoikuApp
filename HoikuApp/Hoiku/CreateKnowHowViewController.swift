//
//  CreateKnowHowViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/11.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD

class CreateKnowHowViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    private var searchKey:String = ""
    private var searchWard:String = ""
    
    //postImage1かpostImage2を判別するためのフラグ
    private var nowTagNumber:Int = 1
    
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let queue = DispatchQueue.global(qos: .userInitiated)
    private let mainQueue = DispatchQueue.main
    
    //投稿する時のカテゴリ、年齢、所要時間のリストを配列にまとめる
    private let categoryArray:[String] = ["","絵本","歌","遊び","製作"]
    private let ratingArray:[String] = ["","0~3歳","4歳","5歳","6歳"]
    private let requiredTimeArray:[String] = ["","15分","30分","60分","1時間~"]
    
    @IBOutlet weak var postImage1: UIImageView!
    @IBOutlet weak var postImage2: UIImageView!
    @IBOutlet weak var naviBar: UINavigationItem!
    
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareSegmented: UISegmentedControl!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categorySegmented: UISegmentedControl!
    
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingSegmented: UISegmentedControl!
    
    
    @IBOutlet weak var requiredTimeLabel: UILabel!
    @IBOutlet weak var requiredSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    
    private func setUpView(){
        //投稿画面のviewの設定
        postImage1.backgroundColor = UIColor.gray
        postImage1.isUserInteractionEnabled = true
        postImage1.tag = 1
        postImage2.backgroundColor = UIColor.gray
        postImage2.isUserInteractionEnabled = true
        postImage2.tag = 2
        
        let dissmissKeyGes:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let tapGesture1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage1))
        let tapGesture2:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage2))
        
        self.view.addGestureRecognizer(dissmissKeyGes)
        postImage1.addGestureRecognizer(tapGesture1)
        postImage2.addGestureRecognizer(tapGesture2)
        
        
        detailTextView.text = ""
        detailTextView.layer.borderWidth = 0.1
        detailTextView.layer.borderColor = UIColor.black.cgColor
        detailTextView.layer.cornerRadius = 5
        
        shareSegmented.removeAllSegments()
        shareSegmented.insertSegment(withTitle: "する", at: 0, animated: true)
        shareSegmented.insertSegment(withTitle: "しない", at: 1, animated: true)
        shareSegmented.selectedSegmentIndex = 1
        shareSegmented.tintColor = UIColor.orange
        shareSegmented.backgroundColor = UIColor.white
        
        
        //カテゴリー要素を設定する
        categorySegmented.removeAllSegments()
        categorySegmented.insertSegment(withTitle: "なし", at: 0, animated: true)
        categorySegmented.insertSegment(withTitle: "絵本", at: 1, animated: true)
        categorySegmented.insertSegment(withTitle: "歌", at: 2, animated: true)
        categorySegmented.insertSegment(withTitle: "遊び", at: 3, animated: true)
        categorySegmented.insertSegment(withTitle: "製作", at: 4, animated: true)
        categorySegmented.selectedSegmentIndex = 0
        categorySegmented.tintColor = UIColor.orange
        categorySegmented.backgroundColor = UIColor.white
        
        
        //対象年齢を設定する
        ratingSegmented.removeAllSegments()
        ratingSegmented.insertSegment(withTitle: "なし", at: 0, animated: true)
        ratingSegmented.insertSegment(withTitle: "0~3歳", at: 1, animated: true)
        ratingSegmented.insertSegment(withTitle: "4歳", at: 2, animated: true)
        ratingSegmented.insertSegment(withTitle: "5歳", at: 3, animated: true)
        ratingSegmented.insertSegment(withTitle: "6歳", at: 4, animated: true)
        ratingSegmented.selectedSegmentIndex = 0
        ratingSegmented.tintColor = UIColor.orange
        ratingSegmented.backgroundColor = UIColor.white
        
        //所要時間を設定する
        requiredSegmented.removeAllSegments()
        requiredSegmented.insertSegment(withTitle: "なし", at: 0, animated: true)
        requiredSegmented.insertSegment(withTitle: "15分", at: 1, animated: true)
        requiredSegmented.insertSegment(withTitle: "30分", at: 2, animated: true)
        requiredSegmented.insertSegment(withTitle: "60分", at: 3, animated: true)
        requiredSegmented.insertSegment(withTitle: "１時間~", at: 4, animated: true)
        requiredSegmented.selectedSegmentIndex = 0
        requiredSegmented.tintColor = UIColor.orange
        requiredSegmented.backgroundColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //actionsheetで投稿する画像をカメラかライブラリから選択させる挙動
    @objc private func chooseImage(){
        let alertSheet = UIAlertController(title: "投稿画像を選択", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //投稿する画像をカメラから選択させる
        let cameraAction = UIAlertAction(title: "カメラから選択", style: UIAlertAction.Style.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .camera
                self.present(pickerController,animated: true,completion: nil)
            }
        }
        
        //投稿する画像をライブラリから選択させる挙動
        let libraryAction = UIAlertAction(title: "ライブラリから選択", style: UIAlertAction.Style.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .photoLibrary
                self.present(pickerController,animated: true,completion: nil)
            }
        }
        
        //画像選択をやめる挙動
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel) { (action) in
        }
        alertSheet.addAction(cameraAction)
        alertSheet.addAction(libraryAction)
        alertSheet.addAction(cancelAction)
        alertSheet.popoverPresentationController?.sourceView = self.view
        
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        let screenSize = UIScreen.main.bounds
        alertSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y:screenSize.size.height, width: 0, height: 0)
        
        
        self.present(alertSheet,animated: true,completion: nil)
    }
    
    
    @objc private func chooseImage1(){
        //画像を判別するフラグをpostImage1の1にする
        nowTagNumber = 1
        chooseImage()
    }
    
    @objc private func chooseImage2(){
        //画像を判別するフラグをpostImage2の2にする
        nowTagNumber = 2
        chooseImage()
    }
    
    //背景をタップするとキーボードが消える
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Debug----------------print")
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        if nowTagNumber == 1{
            //画像判別のフラグnowTagNumberがpostImage1の場合
            postImage1.image = image
        }else if nowTagNumber == 2{
            //画像判別のフラグnowTagNumberがpostImage2の場合
            postImage2.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func postButtonTapped(_ sender: UIBarButtonItem) {
        guard let user = Auth.auth().currentUser else {
            SVProgressHUD.showError(withStatus: "ユーザー作成・ログインされていません")
            return
        }
        
        if Auth.auth().currentUser == nil{
            
        }
        
        if (titleTextField.text?.isEmpty)! || postImage1.image == nil{
            SVProgressHUD.showError(withStatus: "タイトルと写真を最低１枚投稿してください！")
            return
        }
        
        //投稿情報のカテゴリIDを決める
        var categoryId:String!
        if self.categorySegmented.selectedSegmentIndex == 1{
            categoryId = "category_ehon"
        }else if categorySegmented.selectedSegmentIndex == 2{
            categoryId = "category_uta"
        }else if categorySegmented.selectedSegmentIndex == 3{
            categoryId = "category_asobi"
        }else if categorySegmented.selectedSegmentIndex == 4{
            categoryId = "category_seisaku"
        }else{
            categoryId = "設定なし"
        }
        
        //投稿情報の年齢のIDを決める
        var rateId:String!
        if ratingArray[ratingSegmented.selectedSegmentIndex] == "0~3歳"{
            rateId = "rating_0~3"
        }else if ratingArray[ratingSegmented.selectedSegmentIndex] == "4歳"{
            rateId = "rating_4"
        }else if ratingArray[ratingSegmented.selectedSegmentIndex] == "5歳"{
            rateId = "rating_5"
        }else if ratingArray[ratingSegmented.selectedSegmentIndex] == "6歳"{
            rateId = "rating_6"
        }else{
            rateId = "設定なし"
        }
        
        var requiredTimeId:String!
        
        //投稿情報の所要時間のIDを決める
        if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "15分"{
            requiredTimeId = "requiredTime_15"
        }else if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "30分"{
            requiredTimeId = "requiredTime_30"
        }else if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "60分"{
            requiredTimeId = "requiredTime_60"
        }else if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "1時間~"{
            requiredTimeId = "requiredTime_1hour"
        }else{
            requiredTimeId = "設定なし"
        }
        
        
        
        var userId:String!
        
        userId = user.uid
        
        let time = Date.timeIntervalSinceReferenceDate
        
        let name = user.displayName
        
        let ref = Database.database().reference()
        
        let privatePostsDataRef = ref.child(Const.privatePostsData)
        
        let key = privatePostsDataRef.childByAutoId().key
        
        let postRef = ref.child(Const.postPath).child(key)
        let privatePostsRef = ref.child(Const.privatePosts).child(key)
        
        var share = "false"
        
        if shareSegmented.selectedSegmentIndex == 0{
            share = "true"
        }else if shareSegmented.selectedSegmentIndex == 1{
            share = "false"
        }
        
        //投稿情報を辞書型にしてFirebase RealtimeDatabaseに保存する
        let postdic = ["title":titleTextField.text!,"name":name!,"detail":detailTextView.text!,"rateId":rateId,"categoryId":categoryId,"time":String(time),"requiredTimeId":requiredTimeId,"share":"\(share)","userId":userId] as [String : Any]
        
        privatePostsRef.setValue(["user_id":userId,"time":String(time)])
        privatePostsDataRef.child(key).setValue(postdic)
        
        if shareSegmented.selectedSegmentIndex == 0{
            postRef.setValue(postdic)
        }
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        //searchWardを３つのPickerから決めて投稿する写真をアップロードする。
        self.conductSeachWard(key: key)
        self.upload(image: self.postImage1,key: key,num: 0)
        self.upload(image: self.postImage2,key: key,num: 1)
        print("投稿完了")
    }
    
    /// Firebase Storage に画像をアップロードする
    ///
    /// - Parameters:
    ///   - image: 投稿画像のデータ
    ///   - key: 投稿キー（Firebase に保存されている投稿を識別するためのキー）
    ///   - num: 画像を識別するための番号
    private func upload(image:UIImageView,key:String,num:Int){
        //画像の有無の確認
        guard let image = image.image else {
            print("画像がありません。")
            return
        }
        
        let storageRef = Storage.storage().reference(forURL:"gs://hoikuapp.appspot.com")
        
        let imageRef = storageRef.child("image/\(key).\(num).jpg")
        
        let imageData = image.jpegData(compressionQuality: 1.0)!
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let ref = Database.database().reference()
        let postRef = ref.child(Const.postPath).child(key)
        let privatePostsDataRef = ref.child(Const.privatePostsData).child(key)
        
        //FirebaseのStorageに画像を保存する
        imageRef.putData(imageData, metadata: meta){metadata,error in
            if error != nil{
                print("エラー")
            }
            print("アップロード成功")
            
            //Firebaseの画像のURLをダウンロードする
            imageRef.downloadURL{url,error in
                guard let downloadURL = url else{
                    return
                }
                let data = downloadURL.absoluteString
                if let uid = Auth.auth().currentUser?.uid{
                    //共有がtrueのとき投稿の共有データPostDataのpostImageArrayにURLを保存
                    if self.shareSegmented.selectedSegmentIndex == 0{
                        postRef.observeSingleEvent(of:.value, with: { (snapshot) in
                            let postData = PostData(snapshot: snapshot, myId: uid)
                            postData.postImageArray.append(data)
                            let postImageArray = ["postImageArray":postData.postImageArray]
                            postRef.updateChildValues(postImageArray)
                            print("写真追加")
                        }
                        )
                    }
                    self.queue.async {
                        //ユーザー自身の投稿privatePostDataのpostImageArrayに画像のURLを保存
                        privatePostsDataRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            let postPrivateData = PrivatePostsData(snapshot: snapshot, myId: uid)
                            postPrivateData.postImageArray.append(data)
                            let postImageArray = ["postImageArray":postPrivateData.postImageArray]
                            privatePostsDataRef.updateChildValues(postImageArray)
                            print("写真追加２")
                            self.semaphore.signal()
                            SVProgressHUD.setDefaultMaskType(.none)
                        })
                        self.semaphore.wait()
                        self.mainQueue.async {
                            if num == 0{
                                guard let image2 = self.postImage2.image else{
                                    SVProgressHUD.showSuccess(withStatus: "投稿に成功しました！")
                                    return
                                }
                            }else if num == 1{
                                SVProgressHUD.showSuccess(withStatus: "投稿に成功しました！")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /// リセットボタンを押した時の動作
    ///
    /// - Parameter sender: リセットボタン
    @IBAction func resetButtonTapped(_ sender: UIBarButtonItem) {
        
        removeImage(image: postImage1)
        removeImage(image: postImage2)
        
        titleTextField.text = ""
        detailTextView.text = ""
        shareSegmented.selectedSegmentIndex = 1
        
        requiredSegmented.selectedSegmentIndex = 0
        ratingSegmented.selectedSegmentIndex = 0
        categorySegmented.selectedSegmentIndex = 0
    }

    //imageViewのimageがある場合にimagaを取り除く
    private func removeImage(image:UIImageView){
        if image.image != nil{
            image.image = nil
        }
    }
    
    
    /// 投稿の時に検索ワードを決めるメソッド
    ///
    /// - Parameters:
    ///   - pickerView1: カテゴリーピッカー
    ///   - pickerView2:年齢のピッカー
    ///   - pickerView3: 所要時間のピッカー
    ///   - key:投稿キー（Firebase に保存されている投稿を識別するためのキー）
    private func conductSeachWard(key:String){
        let postRef = Database.database().reference().child(Const.postPath).child(key).child("searchWord")
        let privatePostsDataRef = Database.database().reference().child(Const.privatePostsData).child(key).child("searchWord")
        var searchKey:String = ""
        var searchWord:String = ""
        
        if categorySegmented.selectedSegmentIndex == 0{
            if ratingSegmented.selectedSegmentIndex == 0{
                if requiredSegmented.selectedSegmentIndex == 0{
                    //カテゴリーと対象年齢と所要時間の項目が設定なしの場合はnilで返す
                    return
                }else{
                    searchKey = "requiredTime"
                    searchWord = "\(categoryArray[ categorySegmented.selectedSegmentIndex])"
                    let postDic = [searchKey:searchWord]
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue(postDic)
                    }
                    privatePostsDataRef.setValue(postDic)
                }
            }else{
                if requiredSegmented.selectedSegmentIndex == 0{
                    searchKey = "rating"
                    searchWord = "\(ratingArray[ratingSegmented.selectedSegmentIndex])"
                    let postDic = [searchKey:searchWord]
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue(postDic)
                    }
                    //レーティングを保存する
                    privatePostsDataRef.setValue(postDic)
                }else{
                    searchKey = "rating_requiredTime"
                    searchWord = "\(ratingArray[ratingSegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue([searchKey:searchWord,"rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                    }
                    privatePostsDataRef.setValue([searchKey:searchWord,"rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                }
            }
        }else{
            if ratingSegmented.selectedSegmentIndex == 0{
                if requiredSegmented.selectedSegmentIndex == 0{
                    searchKey = "category"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])"
                    let postDic = [searchKey:searchWord]
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue(postDic)
                    }
                    privatePostsDataRef.setValue(postDic)
                }else{
                    searchKey = "category_requiredTime"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                    }
                    privatePostsDataRef.setValue([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                }
            }else{
                if requiredSegmented.selectedSegmentIndex == 0{
                    searchKey = "category_rating"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex])"
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])"])
                    }
                    privatePostsDataRef.setValue([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])"])
                }else{
                    searchKey = "category_rating_requiredTime"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"
                    if shareSegmented.selectedSegmentIndex == 0{
                        postRef.setValue([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","rating_requiredTime":"\(ratingArray[ratingSegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_requiredTime":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_rating":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex])"])
                    }
                    privatePostsDataRef.setValue([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","rating_requiredTime":"\(ratingArray[ratingSegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_requiredTime":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_rating":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex])"])
                }
            }
        }
    }
    
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
}

