//
//  ViewController.swift
//  ChaChat
//
//  Created by daryl on 2023/5/12.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messages: [DataSnapshot]! = [DataSnapshot]()
    
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var originalBackgroudColor: UIColor!


    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        print("root view did appear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // logout
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print("error")
//        }
        
        // check current user
        if Auth.auth().currentUser == nil {
            // go to LoginRegisterViewController
            let loginRegisterViewController = self.storyboard?.instantiateViewController(withIdentifier: "firebaseLoginViewController")
            self.navigationController?.present(loginRegisterViewController!, animated: true)
            
        }
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalBackgroudColor = textField.backgroundColor
        
        databaseRef = Database.database().reference()
        databaseHandle = self.databaseRef.child("messages").observe(.childAdded, with: { dataSnapshot in
            self.messages.append(dataSnapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
            
        })
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        
        // when keyboard is shown, view move
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // when keyboard is hidden, view move
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    deinit {
        self.databaseRef.child("messages").removeObserver(withHandle: databaseHandle)
        
    }
    @objc func keyboardShown(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    @objc func keyboardHidden(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func sendMessage(data: [String: String]) {
        self.databaseRef.child("messages").childByAutoId().setValue(data)
    }

    // MARK: - table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()

        let messages = self.messages[indexPath.row]
        let message = messages.value as! Dictionary<String, String>
        if let text = message[Constants.MessageFields.text] {
//            cell.textLabel?.text = text
            config.text = text
        }
        if let date = message[Constants.MessageFields.dateTime] {
//            cell.detailTextLabel?.text = date
            config.secondaryText = date
        }
        cell.contentConfiguration = config
        
        return cell
    }
    
    // MARK: - text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text?.count == 0 {
            textField.backgroundColor = .red
            return true
        }
        
        // assemble message data
        var data = [Constants.MessageFields.text: textField.text! as! String]
        // data
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"
        data[Constants.MessageFields.dateTime] = dateFormatter.string(from: date)
        
        sendMessage(data: data)
        
        print("ended editing!")
        textField.text = ""
        textField.backgroundColor = originalBackgroudColor
        self.view.endEditing(true)
        return true
    }
}

