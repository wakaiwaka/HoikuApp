//
//  MessageViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/05.
//  Copyright © 2018 若原昌史. All rights reserved.
//
import UIKit
import MessageKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MessageViewController: MessagesViewController,MessagesDisplayDelegate,MessageCellDelegate,MessagesDataSource,MessagesLayoutDelegate,MessageInputBarDelegate{
    
    var postData:PostData!
    
    var dicMessgage:[[String:Any]] = []
    
    var messages:[MockMessage] = []
    
    var ownerUser:Users!
    var currentUser:Users!
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_jp")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = self.messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 10)))
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 10)))
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 10)))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 10)))
        }
        
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        //ドラッグでキーボードを閉じる
        messagesCollectionView.keyboardDismissMode = .onDrag
        
        //Firebase RealtimeDatabaseに保存した投稿内容をコメントに落とし込む
        let ref = Database.database().reference().child(Const.postPath).child(postData.postId!).child("comments")
        ref.observe(.childAdded) { (snapshot) in
            let comment = Comment(snapshot: snapshot)
            
            Database.database().reference().child(Const.users).child(comment.userId!).observe(.value, with: { (snapshot) in
                let user = Users(snapshot: snapshot)
                let sender:Sender = Sender(id: user.userId!, displayName: user.userName!)
                let attributedText = NSAttributedString(string: comment.attributedText!, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                                                      .foregroundColor: UIColor.white])
                let date = self.formatter.date(from: comment.date!)
                
                //編集したデータをモックメッセージに落とし込む
                let mocMessage = MockMessage(attributedText: attributedText, sender: sender, messageId: comment.messageId!, date:date!)
                self.messages.append(mocMessage)
                self.messagesCollectionView.insertSections([self.messages.count - 1])
                //メッセージ画面を再度reloadする
                DispatchQueue.main.async {
                    
                    //self.dicMessgage = self.postData.comments
                    self.messagesCollectionView.reloadData()
                }
            })
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray
        
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func currentSender() -> Sender {
        return Sender(id: currentUser.userId!, displayName: currentUser.userName!)
    }
    
    func otherSender() -> Sender{
        
        return Sender(id: ownerUser.userId!, displayName: ownerUser.userName!)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0{
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                            NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    
    //コメントの上に名前を表示
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    //コメントの下に時間を表示
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner:MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(initials: "")
        avatarView.set(avatar: avatar)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0{
            return 10
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message Tapped")
    }
    
    //sendボタンを押した時の処理p
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let ref = Database.database().reference().child(Const.postPath).child(postData.postId!)
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                self.messages.append(imageMessage)
                let comment = ["comments":self.messages]
                ref.updateChildValues(comment)
                messagesCollectionView.insertSections([self.messages.count - 1])
                
            } else if let text = component as? String {
                if let userId = Auth.auth().currentUser?.uid{
                    let dateString = formatter.string(from: Date())
                    let comment = ["attributedText":text,"userId":userId,"messageId":UUID().uuidString,"date":dateString] as [String : Any]
                    self.dicMessgage.append(comment)
                    let postComment = ["comments":self.dicMessgage]
                    ref.updateChildValues(postComment)
                    
                }
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}

//メッセージのアイコンをなくす
fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

