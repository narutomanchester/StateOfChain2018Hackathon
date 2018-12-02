//
//  SettingViewController.swift
//  StateOfChain
//
//  Created by Hoang Hiep Ho on 12/2/18.
//  Copyright © 2018 Gamedex. All rights reserved.
//

import UIKit
import web3swift

class SettingViewController: UIViewController {

    @IBOutlet var balanceLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            let web3Rinkeby = Web3(infura: .rinkeby)
        
        let rinkebyBalance = try web3Rinkeby.eth.getBalance(address: Address(PUBLIC_ADDRESS_STRING))
          //  let balance : CGFloat = CGFloat(rinkebyBalance/1000000000000000000)
            
        print("Balance \(Web3.Utils.formatToEthereumUnits(rinkebyBalance))")
            balanceLbl.text = "\(Web3.Utils.formatToEthereumUnits(rinkebyBalance)) ETH"
        } catch {
            
        }
        
        
//        print("Balance  \(rinkebyBalance)")
    }


}
