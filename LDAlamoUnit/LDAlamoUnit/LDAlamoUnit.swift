//
//  LDAlamoUnit.swift
//  AlamofireDemo
//
//  Created by Artron_LQQ on 2017/5/28.
//  Copyright © 2017年 Artron. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum LDHTTPType {
    case Get, Post
}

enum LDRequestEncoding {
    case Json, Text, Plist
}

typealias LDAlamoUnit_requestSucessHandle = (_ response: JSON) -> Void

typealias LDAlamoUnit_requestFailedHandle = (_ error: Error) -> Void

typealias LDAlamoUnit_downloadSuccessHandle = (_ data: Data, _ path: String) -> Void

typealias LDAlamoUnit_downloadFailedHandle = (_ error: Error, _ data: Data?) -> Void

typealias LDAlamoUnit_progressHandle = (_ progress: Double) -> Void
class LDAlamoUnit {

    fileprivate static var unit: LDAlamoUnit = LDAlamoUnit()
    private init() { }
    
    fileprivate var baseUrlString: String?
    fileprivate var requestEncoding: LDRequestEncoding = .Json
    fileprivate var headers: [String: String] = [:]
    
    // 身份验证
    fileprivate var user: String?
    fileprivate var password: String?
    
    fileprivate func verifyCharacter(urlString: String, method: LDHTTPType) -> (String, HTTPMethod, ParameterEncoding, [String: String]) {
        
        var url = urlString
        if let str = self.baseUrlString {
            url += str
        }
        
        let httpMethod: HTTPMethod = method == .Get ? HTTPMethod.get : HTTPMethod.post
        
        var encode: ParameterEncoding = JSONEncoding.default
        var headers: [String: String] = [:]
        
        headers["Accept"] = "application/json"
        if self.requestEncoding == .Json {
            
            encode = JSONEncoding.default
            headers["Content-Type"] = "application/json"
        } else if self.requestEncoding == .Text {
            
            encode = URLEncoding.default
            headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        } else if self.requestEncoding == .Plist {
            
            encode = PropertyListEncoding.default
            headers["Content-Type"] = "application/x-plist"
        }
        
        for (key, value) in self.headers {
            headers[key] = value
        }
        
        return (url, httpMethod, encode, headers)
    }


    fileprivate func ldLog<T>(message: T,
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
private extension LDAlamoUnit {
    
    func uploadFile(fileURL: URL, to urlString: String, method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle:  LDAlamoUnit_progressHandle?) {
        
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
    
    func uploadData(data: Data, to urlString: String, method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
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
    
    func upLoadImages(to urlString: String, params:[String:String],name: String, datas: [Data], method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
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
                mutipartData.append(datas[i], withName: name, fileName: "uploadImage\(i)", mimeType: "image/png"/*file*/)
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
    
    
    func uploadFiles(to urlString: String, params:[String:String],name: String, datas: [Any], method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
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
 
    func uploadFileStream(to urlString: String, filePath path: String, httpMethod method: LDHTTPType = .Post,success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
        guard let stream = InputStream(fileAtPath: path) else {
            ldLog(message: "文件地址无效")
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
private extension LDAlamoUnit {
    
    func downLoad(urlString: String, parameters: [String: String]? = nil, to path: String? = nil, resumData: Data? = nil, successs: @escaping LDAlamoUnit_downloadSuccessHandle, failure: @escaping LDAlamoUnit_downloadFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
        var destination: DownloadRequest.DownloadFileDestination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        if let path = path {
            
            destination = { _, _ in
                
                var fileURL: URL
                
                if  let url = URL(string: path) {
                    fileURL = url
                } else {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    fileURL = documentsURL.appendingPathComponent("ldDownloadTmpFile.data")
                }
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
        }
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: .Get)
        
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

// MARK: - Get or Post Request
private extension LDAlamoUnit {
    
    func request(urlString: String, method: LDHTTPType, params : [String : Any]? = nil, success : @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle) {
        
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
//MARK: - Public Method
extension LDAlamoUnit {
    
    /// 添加身份验证, 用于发送请求是验证身份
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - password: 用户密码
    class func authenticate(withUser user: String, password: String) {
        
        LDAlamoUnit.unit.user = user
        LDAlamoUnit.unit.password = password
    }
    
    /// 基础URL
    ///
    /// - Parameter string: 基础URL链接地址
    class func setBaseURLString(_ string: String) {
        
        LDAlamoUnit.unit.baseUrlString = string
    }
    
    /// 请求参数的编码格式
    ///
    /// - Parameter type: 编码格式
    class func setRequestEncoding(_ type: LDRequestEncoding) {
        
        LDAlamoUnit.unit.requestEncoding = type
    }
    
    /// 请求头
    ///
    /// - Parameter headers: 请求头字典
    class func setHTTPHeaders(_ headers: [String: String]) {
        
        for (key, value) in headers {
            
            LDAlamoUnit.unit.headers[key] = value
        }
    }
    
    /// Get请求
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - parameters: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    class func get(_ urlString: String, parameters: [String: Any]? = nil, success : @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle) {
        
        LDAlamoUnit.unit.request(urlString: urlString, method: .Get, params: parameters, success: success, failure: failure)
    }
    
    /// Post请求
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - parameters: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    class func post(_ urlString: String, parameters: [String: Any], success : @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle) {
        
        LDAlamoUnit.unit.request(urlString: urlString, method: .Post, params: parameters, success: success, failure: failure)
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
    class func download(from urlString: String, parameters: [String: String], saveTo to: String, resumData: Data?=nil, success: @escaping LDAlamoUnit_downloadSuccessHandle, failure: @escaping LDAlamoUnit_downloadFailedHandle, progressHandle progress: @escaping LDAlamoUnit_progressHandle) {
        
        LDAlamoUnit.unit.downLoad(urlString: urlString, parameters: parameters, to: to, resumData: resumData, successs: success, failure: failure, progressHandle: progress)
    }
    
    /// 上传文件
    ///
    /// - Parameters:
    ///   - fileURL: 需要上传的文件地址
    ///   - urlString: 上传到的地址
    ///   - method: 上传方式, 默认Post
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    ///   - progressHandle:上传进度
    class func uploadFile(fileURL: URL, to urlString: String, method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle:  LDAlamoUnit_progressHandle?) {
        
        LDAlamoUnit.unit.uploadFile(fileURL: fileURL, to: urlString, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    /// 上传Data数据
    ///
    /// - Parameters:
    ///   - data: 待上传的数据
    ///   - urlString: 上传的URL
    ///   - method: 上传方式, 默认Post
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    ///   - progressHandle: 进度回调
    class func uploadData(data: Data, to urlString: String, method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
        LDAlamoUnit.unit.uploadData(data: data, to: urlString, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    class func upLoadImages(to urlString: String, params:[String:String], name: String, datas: [Data], method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
        LDAlamoUnit.unit.upLoadImages(to: urlString, params: params, name: name, datas: datas, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    class func uploadFiles(to urlString: String, params:[String:String],name: String, datas: [Any], method: LDHTTPType = .Post, success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
        LDAlamoUnit.unit.uploadFiles(to: urlString, params: params, name: name, datas: datas, method: method, success: success, failure: failure, progressHandle: progressHandle)
    }
    
    /// 已文件流的形式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 上传URL
    ///   - path: 文件路径
    ///   - method: 上传方式, 默认Post
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - progressHandle: 进度回调
    class func uploadFileStream(to urlString: String, filePath path: String, httpMethod method: LDHTTPType = .Post,success: @escaping LDAlamoUnit_requestSucessHandle, failure: @escaping LDAlamoUnit_requestFailedHandle, progressHandle: LDAlamoUnit_progressHandle? = nil) {
        
        LDAlamoUnit.unit.uploadFileStream(to: urlString, filePath: path, httpMethod: method, success: success, failure: failure, progressHandle: progressHandle)
    }
}
