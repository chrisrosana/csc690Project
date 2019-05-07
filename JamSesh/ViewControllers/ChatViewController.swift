//
//  ChatViewController.swift
//  JamSesh
//
//  Created by Kurtis Hoang on 4/30/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore
import Parse
import MessageInputBar
import Alamofire

final class ChatViewController: MessagesViewController {
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    var session: PFObject?
    var currUser = PFUser.current()!
    
    deinit {
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id = session!.objectId!
        
        reference = db.collection(["sessions", id, "thread"].joined(separator: "/"))
        
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for session updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        title = session!["sessionName"] as! String
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    // MARK: - Helpers
    
    private func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.index(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            insertNewMessage(message)
            
        default:
            break
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        // 1
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        // 2
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        // 3
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        if(message.sender.displayName == currUser.username)
        {
            //loads the profile image of user
            let imageFile = currUser["image"] as? PFFileObject ?? nil
            if imageFile != nil {
                let urlString = imageFile!.url!
                let url = URL(string: urlString)!
                avatarView.af_setImage(withURL: url)
            }
        }
        else {
            
            var userInfo: PFObject?
            
            let query = PFQuery(className:"UserInfo")
            query.includeKey("user")
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackground { (users, error) in
                if users != nil {
                    for user in users! {
                        let chosenUser = user["user"] as! PFObject
                        if(chosenUser.objectId! == message.sender.id)
                        {
                            userInfo = chosenUser
                            
                            //loads the profile image of user
                            let imageFile = userInfo!["image"] as? PFFileObject ?? nil
                            if imageFile != nil {
                                let urlString = imageFile!.url!
                                let url = URL(string: urlString)!
                                avatarView.af_setImage(withURL: url)
                            }
                            break
                        }
                    }
                }
                else {
                    print("Error: \(String(describing: error))")
                }
            }
        }
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        // 1
        return .init(width: 20, height: 20)
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        // 2
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath,
                           with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        // 3
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 7
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    // 1
    func currentSender() -> Sender {
        return Sender(id: currUser.objectId!, displayName: currUser.username!)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // 3
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    // 4
    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        if(name != currUser.username) {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = NSTextAlignment.left
            return NSAttributedString(
                string: name,
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .caption1),
                    .foregroundColor: UIColor(white: 0.3, alpha: 1),
                    .paragraphStyle: paragraph
                ]
            )
        }
        else
        {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = NSTextAlignment.right
            return NSAttributedString(
                string: name,
                attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .caption1),
                    .foregroundColor: UIColor(white: 0.3, alpha: 1),
                    .paragraphStyle: paragraph
                ]
            )
        }
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let message = Message(user: currUser, content: text)
        
        save(message)
        
        inputBar.inputTextView.text = ""
    }
    
}

// MARK: - UIImagePickerControllerDelegate

//extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//}
