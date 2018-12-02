//
//  SettingViewController.swift
//  StateOfChain
//
//  Created by Hoang Hiep Ho on 12/2/18.
//  Copyright © 2018 Gamedex. All rights reserved.
//

import UIKit
import web3swift

struct KeyWalletModel {
    let address: String
    let data: Data?
}

class SettingViewController: UIViewController {

    @IBOutlet var balanceLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
 
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.getBalance { (result) in
            
        }
    }
    
    func getBalance(completion: @escaping(_ result: CGFloat) -> Void){
        
        let text = PRIVATE_KEY_STRING.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = Data.fromHex(text) else {
            return
        }
        
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: "StateOfChain") else {
            return
        }
        
        guard let wallet = newWallet else {
            return
        }
        
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {
            return
        }
//        guard let address = wallet.addresses?.first?.address  else {
//
//            return
//        }
        let walletModel = KeyWalletModel(address: PUBLIC_ADDRESS_STRING, data: keydata)
        
        /// fix me : change to test net
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        
        let keystoreManager = self.keystoreManager(address: walletModel)
        web3Rinkeby.addKeystoreManager(keystoreManager)
        
       // guard case .success(let gasPriceRinkeby) = web3Rinkeby.eth.getGasPrice() else { return }
        
        let contractAddress = EthereumAddress(SMART_CONTRACT_ADDRESS)!
        
        let contract = web3Rinkeby.contract(Web3.Utils.erc721ABI, at: contractAddress, abiVersion: 2)!
        
       // let fromAddress = UserDefaultsManager.walletAddress!
        
//        var transferOptions = Web3Options.defaultOptions()
//        transferOptions.gasPrice = gasPriceRinkeby
        //  transferOptions.gasPrice = 10000000000000
      //  transferOptions.from = keystoreManager?.addresses?.first
     
//        let nouce = web3Rinkeby.eth.getTransactionCount(address: EthereumAddress(fromAddress)!)
//        guard case .success(let count) = nouce else {return}
        
        
        let transactionIntermediate = contract.method("balanceOf", parameters: [PUBLIC_ADDRESS_STRING] as [AnyObject],options: nil)
       // let transactionIntermediate = contract.method("name", parameters: [] as [AnyObject] ,options: nil)
        
      //  transactionIntermediate?.transaction.nonce = count
        
        
        print(transactionIntermediate?.transaction)
        
        if let result = transactionIntermediate?.call(options: nil).value?.values  {
            print("result \(result.first)")
            if let token = result.first  {
                balanceLbl.text = "\(token) XCoin"
            }
        }
      //  let result = transactionIntermediate?.send(password: "StateOfChain", options: nil)
        
        
    }
    
    func keystoreManager(address : KeyWalletModel) -> KeystoreManager? {
        guard  let data = address.data else {
            return KeystoreManager.defaultManager
        }
        return KeystoreManager([EthereumKeystoreV3(data)!])
    }


}
