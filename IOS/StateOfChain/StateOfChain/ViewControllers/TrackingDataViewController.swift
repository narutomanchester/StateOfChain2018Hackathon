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
    @IBOutlet var totalMinsLbl: UILabel!
    
    var ref: DatabaseReference!
    var moveRef: DatabaseReference!
    var statusRef: DatabaseReference!
    
    var timer : Timer?
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        timer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(prozessTimer), userInfo: nil, repeats: true)
    }
    
    @objc func prozessTimer() {
        counter += 1
        let mins = counter / 60
        let secs = counter % 60
        self.totalMinsLbl.text = "\(mins):\(secs)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRealtimeDatabase()
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
            if let up_and_open_arms = data?["diagonal"] as? Int {
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
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true, completion: nil)
    }
    
}
