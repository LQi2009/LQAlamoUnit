//
//  ViewController.swift
//  LDAlamoUnit
//
//  Created by Artron_LQQ on 2017/6/5.
//  Copyright © 2017年 Artup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LDAlamoUnit.setRequestEncoding(.Text)
        LDAlamoUnit.setBaseURLString("urlBaseString")
        LDAlamoUnit.setHTTPHeaders(["header": "value"])
//        LDAlamoUnit.post("http://testuser.artup.com/artup-user-api/f/login", parameters: ["mobile": "18310246496", "pwd": "123456"], success: { (json) in
//            
//            print(json)
//        }) { (error) in
//            print(error)
//        }
        
        
        
//        LDAlamoUnit.get("http://testuser.artup.com/artup-user-api/f/login?mobile=18310246496&pwd=123456", success: { (json) in
//            
//            print(json)
//        }) { (error) in
//            print(error)
//        }
        
        LDAlamoUnit.get("http://testuser.artup.com/artup-user-api/f/login", parameters: ["mobile": "18310246496", "pwd": "123456"], success: { (json) in
            print(json)
        }) { (error) in
            print(error)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

