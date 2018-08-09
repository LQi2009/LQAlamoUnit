//
//  ViewController.swift
//  LQAlamoUnit
//
//  Created by LiuQiqiang on 2018/8/9.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LQAlamoUnit.startNetworkObserver { (state) in
            print(state)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(LQAlamoUnit.currentNetworkStatus)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

