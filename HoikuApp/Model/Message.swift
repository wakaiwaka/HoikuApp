//
//  Message.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/05.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MessageKit
import CoreLocation


private struct MockLocationItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}

struct MockMessage:MessageType {
    var sender: Sender
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.sender = sender
        self.messageId = messageId
        self.kind = kind
        self.sentDate = date
    }
    
    private struct MockMediaItem: MediaItem {
        
        var url: URL?
        var image: UIImage?
        var placeholderImage: UIImage
        var size: CGSize
        
        init(image: UIImage) {
            self.image = image
            self.size = CGSize(width: 240, height: 240)
            self.placeholderImage = UIImage()
        }
    }
    
    init(location: CLLocation, sender: Sender, messageId: String, date: Date) {
        let locationItem = MockLocationItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = MockMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = MockMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    init(emoji: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }
}
