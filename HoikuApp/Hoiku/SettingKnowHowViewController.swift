//
//  SettingKnowHowViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/09.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FirebaseUI
import SVProgressHUD
import SDWebImage

class SettingKnowHowViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    var myPostData:PrivatePostsData!
    
    var switchBool:Bool = false
    
    let semaphore = DispatchSemaphore(value: 0)
    let queue = DispatchQueue.global(qos: .userInitiated)
    let mainQueue = DispatchQueue.main
    
    
    //postImage1,2に画像が入っているかどうかのフラグ
    var initPostImage1 = false
    var initPostImage2 = false
    
    private var nowTagNumber:Int = 1
    
    let categoryArray:[String] = ["","絵本","歌","遊び","製作"]
    let ratingArray:[String] = ["","0~3歳","4歳","5歳","6歳"]
    let requiredTimeArray:[String] = ["","15分","30分","60分","1時間~"]
    
    @IBOutlet weak var postImage1: UIImageView!
    @IBOutlet weak var postImage2: UIImageView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var categorySegmented: UISegmentedControl!
    @IBOutlet weak var ratingSegmented: UISegmentedControl!
    @IBOutlet weak var requiredSegmented: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    //UIImageViewの中が空かを判定する
    private func checkNoImage(privatePostsData:PrivatePostsData,num:Int) -> Bool{
        if privatePostsData.postImageArray.count >= num + 1{
            if privatePostsData.postImageArray[num].isEmpty == false{
                return true
            }
        }
        return false
    }
    
    private func setUpView(){
        let ref = Database.database().reference()
        
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
        
        
        postImage1.backgroundColor = UIColor.gray
        postImage2.backgroundColor = UIColor.gray
        
        if myPostData.postImageArray.count == 1{
            downLoadImage(num:1,postImage: postImage1)
        }else if myPostData.postImageArray.count == 2{
            downLoadImage(num:1,postImage: postImage1)
            downLoadImage(num:2 ,postImage: postImage2)
        }
        
        if let title = myPostData.title{
            titleTextField.text = title
        }else{
            titleTextField.text = ""
        }
        
        if let detail = myPostData.detail{
            detailTextView.text = detail
        }else{
            detailTextView.text = ""
        }
        
        detailTextView.layer.borderColor = UIColor.darkGray.cgColor
        detailTextView.layer.borderWidth = 0.1
        detailTextView.layer.cornerRadius = 5
        detailTextView.layer.masksToBounds = false
        
        categorySegmented.removeAllSegments()
        categorySegmented.insertSegment(withTitle: "なし", at: 0, animated: true)
        categorySegmented.insertSegment(withTitle: "絵本", at: 1, animated: true)
        categorySegmented.insertSegment(withTitle: "歌", at: 2, animated: true)
        categorySegmented.insertSegment(withTitle: "遊び", at: 3, animated: true)
        categorySegmented.insertSegment(withTitle: "製作", at: 4, animated: true)
        categorySegmented.tintColor = UIColor.orange
        categorySegmented.backgroundColor = UIColor.white
        
        ratingSegmented.removeAllSegments()
        ratingSegmented.insertSegment(withTitle: "なし", at: 0, animated: true)
        ratingSegmented.insertSegment(withTitle: "0~3歳", at: 1, animated: true)
        ratingSegmented.insertSegment(withTitle: "4歳", at: 2, animated: true)
        ratingSegmented.insertSegment(withTitle: "5歳", at: 3, animated: true)
        ratingSegmented.insertSegment(withTitle: "6歳", at: 4, animated: true)
        ratingSegmented.tintColor = UIColor.orange
        ratingSegmented.backgroundColor = UIColor.white
        
        requiredSegmented.removeAllSegments()
        requiredSegmented.insertSegment(withTitle: "なし", at: 0, animated: true)
        requiredSegmented.insertSegment(withTitle: "15分", at: 1, animated: true)
        requiredSegmented.insertSegment(withTitle: "30分", at: 2, animated: true)
        requiredSegmented.insertSegment(withTitle: "60分", at: 3, animated: true)
        requiredSegmented.insertSegment(withTitle: "1時間~", at: 4, animated: true)
        requiredSegmented.tintColor = UIColor.orange
        requiredSegmented.backgroundColor = UIColor.white
        
        if myPostData.categoryId!.isEmpty == false{
            let categoryRef = ref.child(Const.categories).child(myPostData.categoryId!)
            categoryRef.observeSingleEvent(of: .value,with: { (snapshot) in
                let category = Category(snapshot: snapshot)
                let index = self.categoryArray.index(of:category.categoryName!)
                self.categorySegmented.selectedSegmentIndex = index!
            })
        }else{
            self.categorySegmented.selectedSegmentIndex = 0
        }
        
        if myPostData.rateId!.isEmpty == false{
            let ratingRef = ref.child(Const.rating).child(myPostData.rateId!)
            ratingRef.observeSingleEvent(of: .value) { (snapshot) in
                let rating = Rating(snapshot: snapshot)
                let index = self.ratingArray.index(of:rating.rating!)
                self.ratingSegmented.selectedSegmentIndex = index!
            }
        }else{
            self.ratingSegmented.selectedSegmentIndex = 0
        }
        
        
        if myPostData.requiredTimeId!.isEmpty == false{
            let requiredTimeRef = ref.child(Const.requiredTime).child(myPostData.requiredTimeId!)
            requiredTimeRef.observeSingleEvent(of: .value) { (snapshot) in
                let requiredTime = RequiredTime(snapshot: snapshot)
                let index = self.requiredTimeArray.index(of:requiredTime.reuquiredTime!)
                self.requiredSegmented.selectedSegmentIndex = index!
            }
        }else{
            self.requiredSegmented.selectedSegmentIndex = 0
        }
        
    }
    
    
    /// 画像をダウンロードしてpostImageに代入
    ///
    /// - Parameters:
    ///   - num: どちらのpostImage1 ,postImage2を判別するためのフラグ
    ///   - postImage: 投稿画像
    private func downLoadImage(num:Int, postImage:UIImageView){
        if num == 1{
            postImage.sd_setImage(with: URL(string: myPostData.postImageArray[0]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }else{
            postImage.sd_setImage(with: URL(string: myPostData.postImageArray[1]), placeholderImage: nil, options: SDWebImageOptions.refreshCached, completed: nil)
        }
    }
    
    //actionsheetでカメラかライブラリから選択させる
    private func chooseImage(){
        let alertSheet = UIAlertController(title: "投稿画像を選択", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラから選択", style: UIAlertAction.Style.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .camera
                self.present(pickerController,animated: true,completion: nil)
            }
        }
        
        let libraryAction = UIAlertAction(title: "ライブラリから選択", style: UIAlertAction.Style.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .photoLibrary
                self.present(pickerController,animated: true,completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel) { (action) in
        }
        alertSheet.addAction(cameraAction)
        alertSheet.addAction(libraryAction)
        alertSheet.addAction(cancelAction)
        
        self.present(alertSheet,animated: true,completion: nil)
    }
    
    @objc func chooseImage1(){
        nowTagNumber = 1
        chooseImage()
    }
    
    @objc func chooseImage2(){
        nowTagNumber = 2
        chooseImage()
    }
    
    //背景をタップするとキーボードが消える
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        if nowTagNumber == 1{
            postImage1.image = image
        }else if nowTagNumber == 2{
            postImage2.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //投稿内容の変更
    @IBAction func changedKnowHow(_ sender: UIBarButtonItem) {
        
        if (titleTextField.text?.isEmpty)! || postImage1.image == nil{
            SVProgressHUD.showError(withStatus: "タイトルと写真を最低１枚投稿してください！")
            return
        }
        
        var categoryId:String!
        if categoryArray[categorySegmented.selectedSegmentIndex] == "絵本"{
            categoryId = "category_ehon"
        }else if categoryArray[categorySegmented.selectedSegmentIndex] == "歌"{
            categoryId = "category_uta"
        }else if categoryArray[categorySegmented.selectedSegmentIndex] == "遊び"{
            categoryId = "category_asobi"
        }else if categoryArray[categorySegmented.selectedSegmentIndex] == "製作"{
            categoryId = "category_seisaku"
        }else{
            categoryId = ""
        }
        
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
            rateId = ""
        }
        
        var requiredTimeId:String!
        
        if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "15分"{
            requiredTimeId = "requiredTime_15"
        }else if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "30分"{
            requiredTimeId = "requiredTime_30"
        }else if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "60分"{
            requiredTimeId = "requiredTime_60"
        }else if requiredTimeArray[requiredSegmented.selectedSegmentIndex] == "1時間~"{
            requiredTimeId = "requiredTime_1hour"
        }else{
            requiredTimeId = ""
        }
        if let user = Auth.auth().currentUser{
            var userId:String!
            
            userId = user.uid
            
            let time = Date.timeIntervalSinceReferenceDate
            
            let name = user.displayName
            
            let ref = Database.database().reference()
            
            let privatePostsDataRef = ref.child(Const.privatePostsData)
            
            let postRef = ref.child(Const.postPath).child(myPostData.postId!)
            let privatePostsRef = ref.child(Const.privatePosts).child(myPostData.postId!)
            
            let postdic = ["title":titleTextField.text!,"name":name!,"detail":detailTextView.text!,"rateId":rateId,"categoryId":categoryId,"time":String(time),"requiredTimeId":requiredTimeId,"userId":userId] as [String : Any]
            
            if switchBool == true{
                postRef.updateChildValues(postdic)
            }
            privatePostsRef.updateChildValues(["user_id":userId,"time":String(time)])
            privatePostsDataRef.child(myPostData.postId!).updateChildValues(postdic)
            
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.clear)
            
            conductSeachWard(key: self.myPostData.postId!)
            upload(image: self.postImage1,key: self.myPostData.postId!,num: 0,initPost: self.initPostImage1)
            upload(image: self.postImage2,key: self.myPostData.postId!,num: 1,initPost: self.initPostImage2)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initPostImage1 = checkNoImage(privatePostsData: myPostData,num: 0)
        initPostImage2 = checkNoImage(privatePostsData: myPostData,num: 1)
    }

    
    //storageに画像をアップロード
    private func upload(image:UIImageView,key:String,num:Int,initPost:Bool){
        //UIImageViewの中に画像があるかを判定する
        guard let image = image.image else{
            print("画像がありません。")
            return
        }
        let storageRef = Storage.storage().reference(forURL:"gs://hoikuapp.appspot.com")
        
        let imageRef = storageRef.child("image/\(key).\(num).jpg")
        
        let imageData = image.jpegData(compressionQuality: 1.0)!
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        //初めに画面遷移された時のUIImageViewに画像が入っている場合はFirebaseのStorageのファイルを削除する
        if initPost == true{
            imageRef.delete { (error) in
                if let error = error{
                    print(error.localizedDescription)
                    print("画像の削除に失敗しました。")
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.showError(withStatus: "画像の変更に失敗しました")
                    return
                }
                print("画像の削除に成功")
                let storageRef = Storage.storage()
                let imageUrl:String = self.myPostData.postImageArray[num]
                let httpsReference = storageRef.reference(forURL:imageUrl)
            }
        }
        
        let ref = Database.database().reference()
        let postRef = ref.child(Const.postPath).child(key)
        let privatePostsDataRef = ref.child(Const.privatePostsData).child(key)
        imageRef.putData(imageData, metadata: meta){metadata,error in
            if error != nil{
                print("エラー")
            }
            print("アップロード成功")
            //画像のurlをfirebaseに保存
            imageRef.downloadURL{url,error in
                guard let downloadURL = url else{
                    return
                }
                let data = downloadURL.absoluteString
                if let uid = Auth.auth().currentUser?.uid{
                    
                    //投稿の共有がtrueのとき全体投稿にも追加する
                    if self.switchBool == true{
                        postRef.observeSingleEvent(of:.value, with: { (snapshot) in
                            let postData = PostData(snapshot: snapshot, myId: uid)
                            
                            if (postData.postImageArray.count == 0 && num == 0) || (postData.postImageArray.count == 1 && num == 1){
                                postData.postImageArray.insert(data, at: num)
                            }else if (postData.postImageArray.count == 0 && num == 1){
                                postData.postImageArray.insert(data, at: 0)
                            }else{
                                postData.postImageArray[num] = data
                            }
                            
                            let postImageArray = ["postImageArray":postData.postImageArray]
                            postRef.updateChildValues(postImageArray)
                            print("写真追加")
                        }
                        )
                    }
                    
                    //プライベート投稿の投稿
                    self.queue.async {
                        //ユーザー自身の投稿privatePostDataのpostImageArrayに画像のURLを保存
                        privatePostsDataRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            let postPrivateData = PrivatePostsData(snapshot: snapshot, myId: uid)
                            //postImageArrayに写真を代入する
                            if (postPrivateData.postImageArray.count == 0 && num == 0) || (postPrivateData.postImageArray.count == 1 && num == 1){
                                postPrivateData.postImageArray.insert(data, at: num)
                            }else if (postPrivateData.postImageArray.count == 0 && num == 1){
                                postPrivateData.postImageArray.insert(data, at: 0)
                            }else{
                                postPrivateData.postImageArray[num] = data
                            }
                            
                            let postImageArray = ["postImageArray":postPrivateData.postImageArray]
                            privatePostsDataRef.updateChildValues(postImageArray)
                            print("写真追加２")
                            self.semaphore.signal()
                            SVProgressHUD.setDefaultMaskType(.none)
                        })
                        self.semaphore.wait()
                        self.mainQueue.async {
                            if num == 0{
                                //postImage2の画像がからの時にSVProgressHUDを消す
                                if self.postImage2.image == nil {
                                    SVProgressHUD.showSuccess(withStatus: "投稿に成功しました！")
                                }
                            }else if num == 1{
                                SVProgressHUD.showSuccess(withStatus: "投稿に成功しました！")
                            }}}}}}}
    
    
    //Firebaseに保存する投稿情報の検索ワード検索キーを、カテゴリー、対象年齢、所要時間によって決定する。
    private func conductSeachWard(key:String){
        let postRef = Database.database().reference().child(Const.postPath).child(key).child("searchWord")
        let privatePostsDataRef = Database.database().reference().child(Const.privatePostsData).child(key).child("searchWord")
        var searchKey:String = ""
        var searchWord:String = ""
        
        //カテゴリーが設定なしが選択されている場合
        if categorySegmented.selectedSegmentIndex == 0{
            
            //対象年齢が設定なしと選択されている場合
            if ratingSegmented.selectedSegmentIndex == 0{
                
                //所要時間が選択なしと選択されている場合
                if requiredSegmented.selectedSegmentIndex == 0{
                    
                    //全ての選択肢で選択なしとなったため検索ワードと検索キーはなし
                    return
                }else{
                    //所要時間から検索キー検索ワードを決定する
                    searchKey = "requiredTime"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])"
                    let postDic = [searchKey:searchWord]
                    if switchBool == true{
                        postRef.updateChildValues(postDic)
                    }
                    privatePostsDataRef.updateChildValues(postDic)
                }
            }else{
                if requiredSegmented.selectedSegmentIndex == 0{
                    searchKey = "rating"
                    searchWord = "\(ratingArray[ratingSegmented.selectedSegmentIndex ])"
                    let postDic = [searchKey:searchWord]
                    if switchBool == true{
                        postRef.updateChildValues(postDic)
                    }
                    privatePostsDataRef.updateChildValues(postDic)
                }else{
                    searchKey = "rating_requiredTime"
                    searchWord = "\(ratingArray[ratingSegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"
                    if switchBool == true{
                        postRef.updateChildValues([searchKey:searchWord,"rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                    }
                    privatePostsDataRef.updateChildValues([searchKey:searchWord,"rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex ])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                }
            }
        }else{
            if ratingSegmented.selectedSegmentIndex  == 0{
                
                if requiredSegmented.selectedSegmentIndex == 0{
                    searchKey = "category"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])"
                    let postDic = [searchKey:searchWord]
                    if self.switchBool == true{
                        postRef.updateChildValues(postDic)
                    }
                    privatePostsDataRef.updateChildValues(postDic)
                }else{
                    searchKey = "category_requiredTime"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"
                    if self.switchBool == true{
                        postRef.updateChildValues([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                    }
                    privatePostsDataRef.updateChildValues([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex ])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"])
                }
            }else{
                if requiredSegmented.selectedSegmentIndex == 0{
                    searchKey = "category_rating"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex ])"
                    if self.switchBool == true{
                        postRef.updateChildValues([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex ])"])
                    }
                    privatePostsDataRef.updateChildValues([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex])"])
                }else{
                    searchKey = "category_rating_requiredTime"
                    searchWord = "\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex ])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])"
                    
                    //共有がonの場合検索キー検索ワードを作成する
                    if self.switchBool == true{
                        postRef.updateChildValues([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex ])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","rating_requiredTime":"\(ratingArray[ratingSegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_requiredTime":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_rating":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex])"])
                    }
                    
                    //プライベート投稿の検索ワード検索キーを決定する
                    privatePostsDataRef.updateChildValues([searchKey:searchWord,"category":"\(categoryArray[categorySegmented.selectedSegmentIndex])","rating":"\(ratingArray[ratingSegmented.selectedSegmentIndex ])","requiredTime":"\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","rating_requiredTime":"\(ratingArray[ratingSegmented.selectedSegmentIndex ])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_requiredTime":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(requiredTimeArray[requiredSegmented.selectedSegmentIndex])","category_rating":"\(categoryArray[categorySegmented.selectedSegmentIndex])_\(ratingArray[ratingSegmented.selectedSegmentIndex ])"])
                }
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

