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
        
        LQAlamoUnit.config(baseURL: nil, requestEncoding: .json, isCachePostResponse: true, isCacheGetResponse: true, isUseLocalCacheWhenRequestFailed: true)
        
        LQAlamoUnit.post("http://192.168.68.94:8207/forward/getStyleList", parameters: ["loginId": "1ce1c2469e9241ddb9e6", "storeId": "401"], success: { (res) in
            // 获取JSON格式
            res.responseJSON({ (json) in
                print(json)
            })
            // 获取字符串格式
            res.responseText({ (str) in
                
            })
            
            print(Thread.current)
        }) { (error) in
            print(error)
        }
        
//        let req = LQAlamoUnit.post("http://192.168.68.94:8207/forward/getStyleList", parameters: ["loginId": "1ce1c2469e9241ddb9e6", "storeId": "401"], success: { (json) in
//            print(json)
//            print(Thread.current)
//        }) { (error) in
//            print(error)
//        }
//        // 请求取消，会打印异常
//        req.cancel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

