//
//  LQAlamoUnit.swift
//  LQProjectorSwift
//
//  Created by LiuQiqiang on 2018/6/30.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//
/*
 Author：LiuQiqiang
 GitHub：https://github.com/LQi2009/LQAlamoUnit
 QQ：302934443
 */

import UIKit
import Alamofire
import SwiftyJSON

/// 网络请求方式
///
/// - get: get
/// - post: post
enum LQRequestType {
    case get, post
}

/// 网络请求参数编码方式
///
/// - json: json
/// - text: text
/// - plist: plist属性列表
enum LQRequestEncoding {
    case json, text, plist
}

/// 网络状态
///
/// - wifi: Wi-Fi
/// - wwan: wwan 流量
/// - unknown: 网络未知
/// - no: 无网络
enum LQNetworkStatus {
    case wifi, wwan, unknown, no
}

typealias LQAlamoUnit_requestSucessHandle = (_ response: JSON) -> Void
typealias LQAlamoUnit_requestFailedHandle = (_ error: Error) -> Void
typealias LQAlamoUnit_downloadSuccessHandle = (_ data: Data, _ path: String) -> Void
typealias LQAlamoUnit_downloadFailedHandle = (_ error: Error, _ data: Data?) -> Void
typealias LQAlamoUnit_progressHandle = (_ progress: Double) -> Void

//MARK: - Public Method
extension LQAlamoUnit {
    
    /// 添加身份验证, 用于发送请求是验证身份
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - password: 用户密码
    class func authenticate(withUser user: String, password: String) {
        
        LQAlamoUnit.unit.user = user
        LQAlamoUnit.unit.password = password
    }
    
    /// 基础URL
    ///
    /// - Parameter string: 基础URL链接地址
    class func setBaseURLString(_ string: String) {
        
        LQAlamoUnit.unit.baseUrlString = string
    }
    
    /// 请求参数的编码格式
    ///
    /// - Parameter type: 编码格式
    class func setRequestEncoding(_ type: LQRequestEncoding) {
        
        LQAlamoUnit.unit.requestEncoding = type
    }
    
    /// 请求头
    ///
    /// - Parameter headers: 请求头字典
    class func setHTTPHeaders(_ headers: [String: String]) {
        
        for (key, value) in headers {
            
            LQAlamoUnit.unit.headers[key] = value
        }
    }
    
    /// get请求
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - parameters: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    class func get(_ urlString: String, parameters: [String: Any]? = nil, success : @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle) {
        
        LQAlamoUnit.unit.request(urlString: urlString, method: .get, params: parameters, success: success, failure: failure)
    }
    
    /// post请求
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - parameters: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    class func post(_ urlString: String, parameters: [String: Any], success : @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle) {
        
        LQAlamoUnit.unit.request(urlString: urlString, method: .post, params: parameters, success: success, failure: failure)
    }
    
    /// 下载
    ///
    /// - Parameters:
    ///   - urlString: 下载URL
    ///   - parameters: 请求参数
    ///   - to: 保存位置
    ///   - resumData: 断点已下载数据
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - progress: 下载进度
    class func download(from urlString: String, parameters: [String: String], saveTo to: String, resumData: Data?=nil, success: @escaping LQAlamoUnit_downloadSuccessHandle, failure: @escaping LQAlamoUnit_downloadFailedHandle, progressHandle progress: @escaping LQAlamoUnit_progressHandle) {
        
        LQAlamoUnit.unit.downLoad(urlString: urlString, parameters: parameters, to: to, resumData: resumData, successs: success, failure: failure, progressHandle: progress)
    }
    
    /// 上传文件
    ///
    /// - Parameters:
    ///   - fileURL: 需要上传的文件地址
    ///   - urlString: 上传到的地址
    ///   - method: 上传方式, 默认post
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    ///   - progressHandle:上传进度
    class func uploadFile(fileURL: URL, to urlString: String, method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle:  LQAlamoUnit_progressHandle?) {
        
        LQAlamoUnit.unit.uploadFile(fileURL: fileURL, to: urlString, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    /// 上传Data数据
    ///
    /// - Parameters:
    ///   - data: 待上传的数据
    ///   - urlString: 上传的URL
    ///   - method: 上传方式, 默认post
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    ///   - progressHandle: 进度回调
    class func uploadData(data: Data, to urlString: String, method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        LQAlamoUnit.unit.uploadData(data: data, to: urlString, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    /// 上传一组图片
    ///
    /// - Parameters:
    ///   - urlString: 地址URL
    ///   - params: 参数
    ///   - name: 服务端定义接收数据的字段名称
    ///   - datas: 图片的Data数组
    ///   - method: 请求方法，默认post
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    ///   - progressHandle: 进度回调
    class func upLoadImages(to urlString: String, params:[String:String], name: String, datas: [Data], method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        LQAlamoUnit.unit.upLoadImages(to: urlString, params: params, name: name, datas: datas, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    /// 上传一组文件
    ///
    /// - Parameters:
    ///   - urlString: 地址URL
    ///   - params: 参数
    ///   - name: 服务端定义接收数据的字段名称
    ///   - datas: 文件的Data数组
    ///   - method: 请求方法，默认post
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    ///   - progressHandle: 进度回调
    class func uploadFiles(to urlString: String, params:[String:String],name: String, datas: [Any], method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        LQAlamoUnit.unit.uploadFiles(to: urlString, params: params, name: name, datas: datas, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    /// 以文件流的形式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 上传URL
    ///   - path: 文件路径
    ///   - method: 上传方式, 默认post
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - progressHandle: 进度回调
    class func uploadFileStream(to urlString: String, filePath path: String, httpMethod method: LQRequestType = .post,success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        LQAlamoUnit.unit.uploadFileStream(to: urlString, filePath: path, httpMethod: method, success: success, failure: failure, progressHandle: progressHandle)
    }
}

//MARK: - 网络状态监控
extension LQAlamoUnit {
    
    static var isWWANEnable: Bool {
        
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.isReachableOnWWAN else { return false }
        return rs
    }
    
    static var isNetEnable: Bool {
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.isReachable else { return false }
        return rs
    }
    
    static var isWifiEnable: Bool {
        
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.isReachableOnEthernetOrWiFi else { return false }
        return rs
    }
    
    static var currentNetworkStatus: LQNetworkStatus {
        
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.networkReachabilityStatus else { return .unknown }
        
        var status: LQNetworkStatus = .unknown
        
        switch rs {
        case .unknown:
            status = .unknown
        case .notReachable:
            status = .no
        case .reachable(.ethernetOrWiFi):
            status = .wifi
        case .reachable(.wwan):
            status = .wwan
        }
        
        return status
    }
    
    class func startNetworkObserver(_ closure: @escaping (_ status: LQNetworkStatus) -> Void) {
        
        LQAlamoUnit.unit.reachabilityManager?.listener = { status in
            
            switch status {
            case .unknown:
                closure(.unknown)
            case .notReachable:
                closure(.no)
            case .reachable(.ethernetOrWiFi):
                closure(.wifi)
            case .reachable(.wwan):
                closure(.wwan)
            }
        }
        
        LQAlamoUnit.unit.reachabilityManager?.startListening()
    }
    
    class func stopNetworkObserver() {
        LQAlamoUnit.unit.reachabilityManager?.stopListening()
    }
}

class LQAlamoUnit {
    
    fileprivate static var unit: LQAlamoUnit = LQAlamoUnit()
    private init() { }
    
    fileprivate var baseUrlString: String?
    fileprivate var requestEncoding: LQRequestEncoding = .plist
    fileprivate var headers: [String: String] = [:]
    
    /// 身份验证
    fileprivate var user: String?
    fileprivate var password: String?
    
    /// 网络监控
    private var reachabilityManager = Alamofire.NetworkReachabilityManager.init()
    
    /// 将自定义类型转换为Alamofire所需的类型
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - method: 请求方式
    /// - Returns: (URL, 请求方式, 请求参数编码方式, 请求头)
    fileprivate func verifyCharacter(urlString: String, method: LQRequestType) -> (String, HTTPMethod, ParameterEncoding, [String: String]) {
        
        var url = urlString
        if let str = self.baseUrlString {
            if url.hasPrefix("http") == false {
                url += str
            }
        }
        
        let httpMethod: HTTPMethod = method == .get ? HTTPMethod.get : HTTPMethod.post
        
        var encode: ParameterEncoding = JSONEncoding.default
        var headers: [String: String] = [:]
        
        headers["Accept"] = "application/json"
        if self.requestEncoding == .json {
            
            encode = JSONEncoding.default
            headers["Content-Type"] = "application/json"
        } else if self.requestEncoding == .text {
            
            encode = URLEncoding.default
            headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        } else if self.requestEncoding == .plist {
            
            encode = PropertyListEncoding.default
            headers["Content-Type"] = "application/x-plist"
        }
        
        for (key, value) in self.headers {
            headers[key] = value
        }
        
        return (url, httpMethod, encode, headers)
    }
    
    
    fileprivate func LQLog<T>(message: T,
                              file: String = #file,
                              method: String = #function,
                              line: Int = #line)
    {
        #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        #endif
    }
}
//MARK: - Upload Files
private extension LQAlamoUnit {
    
    func uploadFile(fileURL: URL, to urlString: String, method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle:  LQAlamoUnit_progressHandle?) {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        
        Alamofire.upload(fileURL, to: urlString, method: requestCharaters.1, headers: requestCharaters.3).uploadProgress { (progress) in
            
            if let progressHandle = progressHandle {
                progressHandle(progress.fractionCompleted)
            }
            }.responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        success(json)
                    }
                case .failure(let error):
                    failure(error)
                }
        }
    }
    
    func uploadData(data: Data, to urlString: String, method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        Alamofire.upload(data, to: requestCharaters.0, method: requestCharaters.1, headers: requestCharaters.3).uploadProgress { (progress) in
            if let progressHandle = progressHandle {
                progressHandle(progress.fractionCompleted)
            }
            }.responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        success(json)
                    }
                case .failure(let error):
                    failure(error)
                }
        }
    }
    
    func upLoadImages(to urlString: String, params:[String:String],name: String, datas: [Data], method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        var headers = requestCharaters.3
        headers["content-type"] = "multipart/form-data"
        
        Alamofire.upload(multipartFormData: { (mutipartData) in
            
            for (key, value) in params {
                if let data = value.data(using: String.Encoding.utf8) {
                    mutipartData.append(data, withName: key)
                }
            }
            for i in 0..<datas.count {
                mutipartData.append(datas[i], withName: name, fileName: "uploadImage\(i)", mimeType: "image/jpg"/*file*/)
            }
            //            autoreleasepool{
            //
            //            }
            
        },to: requestCharaters.0,
          method: requestCharaters.1,
          headers: headers,
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            success(json)
                        }
                    case .failure(let error):
                        failure(error)
                    }
                    }.uploadProgress(closure: { (progress) in
                        if let progressHandle = progressHandle {
                            progressHandle(progress.fractionCompleted)
                        }
                    })
            case .failure(let encodingError):
                failure(encodingError)
            }
        })
    }
    
    func uploadFiles(to urlString: String, params:[String:String],name: String, datas: [Any], method: LQRequestType = .post, success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        var headers = requestCharaters.3
        headers["content-type"] = "multipart/form-data"
        
        Alamofire.upload(multipartFormData: { (mutipartData) in
            
            for (key, value) in params {
                if let data = value.data(using: String.Encoding.utf8) {
                    mutipartData.append(data, withName: key)
                }
            }
            
            for i in 0..<datas.count {
                let tmp = datas[i]
                if tmp is Data {
                    let data = tmp as! Data
                    mutipartData.append(data, withName: name, fileName: "uploadFile\(i)", mimeType: "image/png"/*file*/)
                } else if tmp is String {
                    let str = tmp as! String
                    let fm = FileManager.default
                    if fm.fileExists(atPath: str) {
                        var url = URL(string: str)
                        if let url = url {
                            
                            let data = try? Data.init(contentsOf: url)
                            if let data = data {
                                mutipartData.append(data, withName: name, fileName: "uploadFile\(i)", mimeType: "image/png"/*file*/)
                            }
                        } else {
                            url = URL(fileURLWithPath: str)
                            if let url = url {
                                
                                let data = try? Data.init(contentsOf: url)
                                if let data = data {
                                    mutipartData.append(data, withName: name, fileName: "uploadFile\(i)", mimeType: "image/png"/*file*/)
                                }
                            }
                        }
                    }
                } else if tmp is URL {
                    let url = tmp as! URL
                    let data = try? Data.init(contentsOf: url)
                    if let data = data {
                        mutipartData.append(data, withName: name, fileName: "uploadFile\(i)", mimeType: "image/png"/*file*/)
                    }
                }
            }
            //            autoreleasepool{
            //
            //            }
            
        },to: requestCharaters.0,
          method: requestCharaters.1,
          headers: headers,
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            success(json)
                        }
                    case .failure(let error):
                        failure(error)
                    }
                    }.uploadProgress(closure: { (progress) in
                        if let progressHandle = progressHandle {
                            progressHandle(progress.fractionCompleted)
                        }
                    })
            case .failure(let encodingError):
                failure(encodingError)
            }
        })
    }
    
    func uploadFileStream(to urlString: String, filePath path: String, httpMethod method: LQRequestType = .post,success: @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        guard let stream = InputStream(fileAtPath: path) else {
            LQLog(message: "文件地址无效")
            return
        }
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        var headers = requestCharaters.3
        headers["content-type"] = "multipart/form-data"
        
        Alamofire.upload(stream, to: urlString, method: requestCharaters.1, headers: headers).uploadProgress(closure: { (progress) in
            
            if let progressHandle = progressHandle {
                
                progressHandle(progress.fractionCompleted)
                
            }
        }).responseJSON { (response) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    success(json)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
}

//MARK: - download Files
private extension LQAlamoUnit {
    
    func downLoad(urlString: String, parameters: [String: String]? = nil, to path: String? = nil, resumData: Data? = nil, successs: @escaping LQAlamoUnit_downloadSuccessHandle, failure: @escaping LQAlamoUnit_downloadFailedHandle, progressHandle: LQAlamoUnit_progressHandle? = nil) {
        
        var destination: DownloadRequest.DownloadFileDestination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        if let path = path {
            
            destination = { _, _ in
                
                var fileURL: URL
                
                if  let url = URL(string: path) {
                    fileURL = url
                } else {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    fileURL = documentsURL.appendingPathComponent("LQDownloadTmpFile.data")
                }
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
        }
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: .get)
        
        let request: DownloadRequest
        
        if let resumData = resumData {
            request = Alamofire.download(resumingWith: resumData, to: destination)
        } else {
            request = Alamofire.download(requestCharaters.0, method: requestCharaters.1, parameters: parameters, encoding: requestCharaters.2, headers: requestCharaters.3, to: destination)
        }
        
        request.responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.result.value, let path = response.destinationURL?.path {
                    successs(data, path)
                }
                
            case .failure(let error):
                failure(error, response.resumeData)
            }
            }.downloadProgress { (progress) in
                if let progressHandle = progressHandle {
                    progressHandle(progress.fractionCompleted)
                }
        }
    }
}

// MARK: - get or post Request
private extension LQAlamoUnit {
    
    func request(urlString: String, method: LQRequestType, params : [String : Any]? = nil, success : @escaping LQAlamoUnit_requestSucessHandle, failure: @escaping LQAlamoUnit_requestFailedHandle) {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        let dataRequest: DataRequest
        // 带有验证
        if let user = self.user, let psw = self.password {
            
            if let authHeader = Request.authorizationHeader(user: user, password: psw) {
                headers[authHeader.key] = authHeader.value
            }
            
            dataRequest = Alamofire.request(requestCharaters.0, method: requestCharaters.1, parameters: params, encoding: requestCharaters.2, headers: requestCharaters.3)
                .validate().authenticate(user: user, password: psw, persistence: URLCredential.Persistence.forSession)
        } else {
            dataRequest = Alamofire.request(requestCharaters.0, method: requestCharaters.1, parameters: params, encoding: requestCharaters.2, headers: requestCharaters.3)
                .validate()
        }
        
        dataRequest.responseJSON { (response) in
            
            switch response.result{
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    success(json)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
}
