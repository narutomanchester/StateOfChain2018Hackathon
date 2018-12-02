//
//  TrackingViewController.swift
//  StateOfChain
//
//  Created by Hoang Hiep Ho on 12/1/18.
//  Copyright © 2018 Gamedex. All rights reserved.
//

import UIKit
import AVFoundation

class TrackingViewController: UIViewController {
    
    @IBOutlet var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //webView.loadRequest(URLRequest(url: URL(string: "https://storage.googleapis.com/tfjs-examples/webcam-transfer-learning/dist/index.html")!))
//        startBtn.backgroundColor = UIColor.white
//        startBtn.layer.cornerRadius = startBtn.frame.height / 2.5
//        startBtn.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func invokeBtn(_ sender: Any) {
//        if let url = URL(string: "https://storage.googleapis.com/tfjs-examples/webcam-transfer-learning/dist/index.html") {
//            UIApplication.shared.open(url, options: [:])
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingDataViewController") as! TrackingDataViewController
                self.present(vc, animated: false, completion: nil)
//            }
//            
//        }
    }
    


}
