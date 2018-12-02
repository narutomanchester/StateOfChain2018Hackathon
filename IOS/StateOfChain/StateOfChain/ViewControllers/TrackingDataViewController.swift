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
    var moveRef: DatabaseReference!
    var statusRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRealtimeDatabase()
        setupView()
    }
    
    func setupView(){
        self.closeBtn.layer.cornerRadius = 7
        self.closeBtn.layer.masksToBounds = true
    }
    
    func setupRealtimeDatabase(){
        ref = Database.database().reference()
        
        moveRef = ref.child("test")
        let refHandleMove : DatabaseHandle? = moveRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary
            let data = postDict?["data"] as? NSDictionary
            if let love = data?["love"] as? Int {
                self.move3Lbl.text = "\(love) times"
            }
            if let open_close_arms = data?["open_close_arms"] as? Int {
                self.move1Lbl.text = "\(open_close_arms) times"
            }
            if let up_and_open_arms = data?["up_and_open_arms"] as? Int {
                self.move2Lbl.text = "\(up_and_open_arms) times"
            }
            
            print(postDict)
        })
        
        statusRef = ref.child("status")
        let refHandleStatus : DatabaseHandle? = statusRef.observe(DataEventType.value, with: { (snapshot) in
            print(snapshot.value)
            if let postDict = snapshot.value as? Bool{
                if (postDict){
                    self.closeBtn.isEnabled = false
                } else {
                    self.closeBtn.isEnabled = true
                }
            }
            
        })

    }

    @IBAction func invokeCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
