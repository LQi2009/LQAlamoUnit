//
//  ViewController.swift
//  LQAlamoUnitDemo
//
//  Created by LiuQiqiang on 2018/8/9.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        LQAlamoUnit.startNetworkObserver { (status) in
            print(status)
        }
        
        LQAlamoUnit.post("http://192.168.68.94:8207/forward/getStyleList", parameters: ["loginId": "1ce1c2469e9241ddb9e6", "storeId": "401"], success: { (json) in
            print(json)
            print(Thread.current)
        }) { (error) in
            print(error)
        }
        
        let req = LQAlamoUnit.post("http://192.168.68.94:8207/forward/getStyleList", parameters: ["loginId": "1ce1c2469e9241ddb9e6", "storeId": "401"], success: { (json) in
            print(json)
            print(Thread.current)
        }) { (error) in
            print(error)
        }
        // 请求取消，会打印异常
        req.cancel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

