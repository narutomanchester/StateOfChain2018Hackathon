//
//  ActivityViewController.swift
//  StateOfChain
//
//  Created by Hoang Hiep Ho on 12/1/18.
//  Copyright © 2018 Gamedex. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet var move1View: UIView!
    @IBOutlet var move2View: UIView!
    @IBOutlet var move3View: UIView!
    @IBOutlet var move1Lbl: UILabel!
    @IBOutlet var move2Lbl: UILabel!
    @IBOutlet var move3Lbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        move1View.layer.masksToBounds = true
        move1View.layer.cornerRadius = 10
        
        move2View.layer.masksToBounds = true
        move2View.layer.cornerRadius = 10
        
        move3View.layer.masksToBounds = true
        move3View.layer.cornerRadius = 10
    }
    
    

}
