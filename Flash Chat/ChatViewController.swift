//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Instance variables
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting self as the delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        // Setting self as the delegate of the text field
        messageTextfield.delegate = self
        
        // Setting the tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        // Registering MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")

        configureTableView()
        
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    // Declaring cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].messageSender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        return cell
    }
    
    // declaring numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
        
    // tableViewTapped defnition (to reduce text edit size)
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    
    // declaring configureTableView
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    // Declaring textFieldDidBeginEditing, textFieldDidEndEditing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // remembering to disambiguate (self) during closures
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase

    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        // Sending the message to Firebase and saving in our DB
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["messageSender": Auth.auth().currentUser?.email,
                                 "messageBody": messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
    }
    
    // defining retrieveMessages method (making sure we reference the same `child` as our
    // `send` method
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        // observing changes in DB
        messageDB.observe(.childAdded) { (snapshot) in
            // formatting change into new message, dealing with Any? type,
            // assuming we're going to get the `dict` we created
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["messageBody"]!
            let sender = snapshotValue["messageSender"]!
            
            let tempMessage : Message = Message()
            tempMessage.messageBody = text
            tempMessage.messageSender = sender
            
            self.messageArray.append(tempMessage)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        // logging out the user; need to handle error throw and then switch view
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error, there was a problem signing out.")
        }
        
    }
    


}
