//
//  TrackingDataViewController.swift
//  StateOfChain
//
//  Created by Hoang Hiep Ho on 12/2/18.
//  Copyright © 2018 Gamedex. All rights reserved.
//

import UIKit
import Firebase

class TrackingDataViewController: UIViewController {

    @IBOutlet var closeBtn: UIButton!
    @IBOutlet var move1Lbl: UILabel!
    @IBOutlet var move2Lbl: UILabel!
    @IBOutlet var move3Lbl: UILabel!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        
       // let userID = Auth.auth().currentUser?.uid
        ref.child("hashads-7968e").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
//            let username = value?["username"] as? String ?? ""
//            let user = User(username: username)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    @IBAction func invokeCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
