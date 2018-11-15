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
public enum LQHTTPMethod {
    case get, post
}

/// 网络请求参数编码方式
///
/// - json: json
/// - text: 字符串
/// - plist: 表单
public enum LQRequestEncoding {
    case json, text, plist
}

/// 返回数据格式
///
/// - json: json
/// - text: 字符串
/// - plist: 表单
/// - data: 二进制
public enum LQResponseEncoding {
    case json, text, plist, data
}

/// 网络状态
///
/// - wifi: Wi-Fi
/// - wwan: wwan 流量
/// - unknown: 网络未知
/// - no: 无网络
public enum LQNetworkStatus {
    case wifi, wwan, unknown, no
}

public typealias LQUploadRequest = UploadRequest
public typealias LQDownloadRequest = DownloadRequest
public typealias LQRequest = DataRequest
public typealias LQAlamoUnit_requestSucessHandler = (_ response: Any) -> Void
public typealias LQAlamoUnit_requestFailedHandler = (_ error: Error) -> Void
public typealias LQAlamoUnit_downloadSuccessHandler = (_ data: Data, _ path: String) -> Void
public typealias LQAlamoUnit_downloadFailedHandler = (_ error: Error, _ data: Data?) -> Void
public typealias LQAlamoUnit_progressHandler = (_ progress: Double) -> Void
public typealias LQAlamoUnit_uploadRequestHandler = (_ req: LQUploadRequest) -> Void

//MARK: - Public Method
extension LQAlamoUnit {
    
    /// 一次性配置请求数据
    /// 如果需要单独配置，请使用其他相应方法
    ///
    /// - Parameters:
    ///   - urlString: 基本URL地址
    ///   - req: 请求参数编码方式, 默认.json
    ///   - res: 返回数据编码方式, 默认.json
    func config(baseURL urlString: String,
                requestEncoding req: LQRequestEncoding = .json,
                requestEncoding res:LQResponseEncoding = .json) {
        
        LQAlamoUnit.unit.baseUrlString = urlString
        LQAlamoUnit.unit.requestEncoding = req
        LQAlamoUnit.unit.responseEncoding = res
    }
    
    /// 设置请求头
    ///
    /// - Parameter headers: 请求头字典
    public class func configHTTPHeaders(_ headers: [String: String]) {
        
        for (key, value) in headers {
            
            LQAlamoUnit.unit.headers[key] = value
        }
    }
    
    /// 添加身份验证, 用于发送请求是验证身份, 相关数据会体现在请求头中
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - password: 用户密码
    public class func authenticate(withUser user: String, password: String) {
        
        LQAlamoUnit.unit.user = user
        LQAlamoUnit.unit.password = password
    }
    
    /// 更新基础URL
    /// 如果有多个基础URL，在发送请求时，调用此方法修改
    ///
    /// - Parameter string: 基础URL链接地址
    public class func updateBaseURLString(_ string: String) {
        
        LQAlamoUnit.unit.baseUrlString = string
    }
    
    /// 请求参数的编码格式
    ///
    /// - Parameter type: 编码格式
    public class func updateRequestEncoding(_ type: LQRequestEncoding) {
        
        LQAlamoUnit.unit.requestEncoding = type
    }
    
    /// 返回数据的编码格式
    ///
    /// - Parameter type: 编码格式
    public class func updateResponseEncoding(_ type: LQResponseEncoding) {
        
        LQAlamoUnit.unit.responseEncoding = type
    }
    
    /// get请求
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - parameters: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func get(_ urlString: String,
                          parameters: [String: Any]? = nil,
                          success : @escaping LQAlamoUnit_requestSucessHandler,
                          failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQRequest {
        
        return LQAlamoUnit.unit.request(urlString: urlString,
                                 method: .get,
                                 params: parameters,
                                 success: success,
                                 failure: failure)
    }
    
    /// post请求
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - parameters: 请求参数
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func post(_ urlString: String,
                           parameters: [String: Any],
                           success : @escaping LQAlamoUnit_requestSucessHandler,
                           failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQRequest {
        
        return LQAlamoUnit.unit.request(urlString: urlString,
                                 method: .post,
                                 params: parameters,
                                 success: success,
                                 failure: failure)
    }
    
    /// 下载
    ///
    /// - Parameters:
    ///   - urlString: 下载URL
    ///   - parameters: 请求参数
    ///   - to: 保存位置
    ///   - resumData: 断点已下载数据
    ///   - progress: 下载进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func download(from urlString: String,
                               parameters: [String: String],
                               saveTo to: String,
                               resumData: Data?=nil,
                               progressHandler progress: @escaping LQAlamoUnit_progressHandler,
                               success: @escaping LQAlamoUnit_downloadSuccessHandler,
                               failure: @escaping LQAlamoUnit_downloadFailedHandler) -> LQDownloadRequest {
        
        return LQAlamoUnit.unit.download(from: urlString,
                                  parameters: parameters,
                                  saveTo: to,
                                  resumData: resumData,
                                  progressHandler: progress,
                                  successs: success,
                                  failure: failure)
    }
    
    /// 上传文件
    ///
    /// - Parameters:
    ///   - urlString: 上传到的地址
    ///   - fileURL: 需要上传的文件地址
    ///   - method: 上传方式, 默认post
    ///   - progressHandle:上传进度
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func uploadFile(to urlString: String,
                                 fileURL: URL,
                                 method: LQHTTPMethod = .post,
                                 progressHandler:  LQAlamoUnit_progressHandler?,
                                 success: @escaping LQAlamoUnit_requestSucessHandler,
                                 failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest {
        
        return LQAlamoUnit.unit.uploadFile(to: urlString,
                                    fileURL: fileURL,
                                    method: method,
                                    progressHandler: progressHandler,
                                    success: success,
                                    failure: failure)
    }
    
    /// 上传Data数据
    ///
    /// - Parameters:
    ///   - urlString: 上传的URL
    ///   - data: 待上传的数据
    ///   - method: 上传方式, 默认post
    ///   - progressHandle: 进度回调
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func uploadData(to urlString: String,
                                 data: Data,
                                 method: LQHTTPMethod = .post,
                                 progressHandler: LQAlamoUnit_progressHandler? = nil,
                                 success: @escaping LQAlamoUnit_requestSucessHandler,
                                 failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest {
        
        return LQAlamoUnit.unit.uploadData(to: urlString,
                                    data: data,
                                    method: method,
                                    progressHandler: progressHandler,
                                    success: success,
                                    failure: failure)
    }
    
    /// 上传一组文件
    ///
    /// - Parameters:
    ///   - urlString: 地址URL
    ///   - params: 参数
    ///   - name: 服务端定义接收数据的字段名称
    ///   - datas: 图片的Data数组
    ///   - mimeType: 文件类型
    ///   - method: 请求方法，默认post
    ///   - uploadRequestHandler: 回调上传实例对象，用于取消请求
    ///   - progressHandle: 进度回调
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    public class func uploadFiles(to urlString: String,
                                   params:[String:String],
                                   name: String,
                                   datas: [Any],
                                   mimeType: String = "image/jpeg",
                                   method: LQHTTPMethod = .post,
                                   uploadRequestHandler: LQAlamoUnit_uploadRequestHandler? = nil,
                                   progressHandler: LQAlamoUnit_progressHandler? = nil,
                                   success: @escaping LQAlamoUnit_requestSucessHandler,
                                   failure: @escaping LQAlamoUnit_requestFailedHandler) {
        
        LQAlamoUnit.unit.uploadMutipartData(to: urlString,
                                            params: params,
                                            name: name,
                                            mimeType: mimeType,
                                            files: datas,
                                            method: method,
                                            uploadRequestHandler: uploadRequestHandler,
                                            progressHandler: progressHandler,
                                            success: success,
                                            failure: failure)
    }
    
    /// 以文件流读取的形式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 上传URL
    ///   - path: 文件路径
    ///   - method: 上传方式, 默认post
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - progressHandle: 进度回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func uploadFileStream(to urlString: String, filePath path: String, httpMethod method: LQHTTPMethod = .post,success: @escaping LQAlamoUnit_requestSucessHandler, failure: @escaping LQAlamoUnit_requestFailedHandler, progressHandler: LQAlamoUnit_progressHandler? = nil) -> LQUploadRequest? {
        
        return LQAlamoUnit.unit.uploadFileStream(to: urlString, filePath: path, httpMethod: method, progressHandler: progressHandler, success: success, failure: failure)
    }
}

//MARK: - 网络状态监控
extension LQAlamoUnit {
    
    public static var isWWANEnable: Bool {
        
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.isReachableOnWWAN else { return false }
        return rs
    }
    
    public static var isNetEnable: Bool {
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.isReachable else { return false }
        return rs
    }
    
    public static var isWifiEnable: Bool {
        
        guard let rs = LQAlamoUnit.unit.reachabilityManager?.isReachableOnEthernetOrWiFi else { return false }
        return rs
    }
    
    /// 当前的网络状态
    public static var currentNetworkStatus: LQNetworkStatus {
        
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
    
    /// 开始网络监控
    ///
    /// - Parameter closure: 当网络发生变化时的回调
    public class func startNetworkObserver(_ closure: @escaping (_ status: LQNetworkStatus) -> Void) {
        
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
    
    public class func stopNetworkObserver() {
        LQAlamoUnit.unit.reachabilityManager?.stopListening()
    }
}

public class LQAlamoUnit {
    
    fileprivate static var unit: LQAlamoUnit = LQAlamoUnit()
    private init() { }
    
    fileprivate var baseUrlString: String?
    fileprivate var requestEncoding: LQRequestEncoding = .json
    fileprivate var responseEncoding: LQResponseEncoding = .json
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
    fileprivate func verifyCharacter(urlString: String, method: LQHTTPMethod) -> (String, HTTPMethod, ParameterEncoding, [String: String]) {
        
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
    
    /// 以URL方式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - fileURL: 本地文件URL
    ///   - method: 请求方式
    ///   - progressHandler: 上传进度回调
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    func uploadFile(to urlString: String,
                    fileURL: URL,
                    method: LQHTTPMethod = .post,
                    progressHandler:  LQAlamoUnit_progressHandler?,
                    success: @escaping LQAlamoUnit_requestSucessHandler,
                    failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        let req = Alamofire.upload(fileURL, to: urlString, method: requestCharaters.1, headers: requestCharaters.3).uploadProgress { (progress) in
            
            if let progressHandle = progressHandler {
                progressHandle(progress.fractionCompleted)
            }
            }
        
        handlerResponseByRequest(req, success: success, failure: failure)
        
        return req
//            .responseJSON { (response) in
//
//                switch response.result {
//                case .success:
//                    if let value = response.result.value {
//                        let json = JSON(value)
//                        success(json)
//                    }
//                case .failure(let error):
//                    failure(error)
//                }
//        }
    }
    
    /// 一般上传文件方式，适合上传数据量不大的文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - data: 文件数据
    ///   - method: 请求方式
    ///   - progressHandler: 上传进度条
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    func uploadData(to urlString: String,
                    data: Data,
                    method: LQHTTPMethod = .post,
                    progressHandler: LQAlamoUnit_progressHandler? = nil,
                    success: @escaping LQAlamoUnit_requestSucessHandler,
                    failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        let req = Alamofire.upload(data, to: requestCharaters.0, method: requestCharaters.1, headers: requestCharaters.3).uploadProgress { (progress) in
            
            if let progressHandle = progressHandler {
                progressHandle(progress.fractionCompleted)
            }
            }
        
        handlerResponseByRequest(req, success: success, failure: failure)
        
        return req
//            .responseJSON { response in
//                switch response.result {
//                case .success:
//                    if let value = response.result.value {
//                        let json = JSON(value)
//                        success(json)
//                    }
//                case .failure(let error):
//                    failure(error)
//                }
//        }
    }
    
    /// 上传文件
    ///
    /// - Parameters:
    ///   - urlString: 网络URL地址
    ///   - params: 参数
    ///   - name: 服务器段定义接收文件的字段名称
    ///   - mimeType: 文件的类型，默认值为图片："image/jpeg"
    ///   - files: 文件数组，内容可以为Data、String（文件路径/资源文件名称）、UIImage对象
    ///   - method: 请求方式
    ///   - uploadRequestHandler: 回调上传实例对象，用于取消请求
    ///   - progressHandler: 上传进度条
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    func uploadMutipartData(to urlString: String,
                     params:[String:String],
                     name: String,
                     mimeType: String = "image/jpeg",
                     files: [Any],
                     method: LQHTTPMethod = .post,
                     uploadRequestHandler: LQAlamoUnit_uploadRequestHandler? = nil,
                     progressHandler: LQAlamoUnit_progressHandler? = nil,
                     success: @escaping LQAlamoUnit_requestSucessHandler,
                     failure: @escaping LQAlamoUnit_requestFailedHandler) {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        var headers = requestCharaters.3
        headers["content-type"] = "multipart/form-data"
        
        Alamofire.upload(multipartFormData: { (mutipartData) in
            
            for (key, value) in params {
                if let data = value.data(using: String.Encoding.utf8) {
                    mutipartData.append(data, withName: key)
                }
            }
            
            for (index, obj) in files.enumerated() {
                
                let fileName = self.randomString()
                
                if let data = obj as? Data {
                    
                    mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: mimeType)
                    /* let data = obj as? Data end */
                } else if let string = obj as? String {
                 
                    let fm = FileManager.default
                    if fm.fileExists(atPath: string) {
                        
                        if let url = URL(string: string) {
                            if let data = try? Data(contentsOf: url) {
                                mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: mimeType)
                            }
                        } else {
                            
                            let url = URL(fileURLWithPath: string)
                            if let data = try? Data.init(contentsOf: url) {
                                
                                mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: mimeType)
                            }
                        }
                    } else {
                        // 如果不是有效的文件路径，再去判断是否是资源文件名称
                        if let url = Bundle.main.url(forResource: string, withExtension: nil) {
                            
                            if let data = try? Data.init(contentsOf: url) {
                                
                                mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: mimeType)
                            }
                        }
                        
                    }
                    /* if let string = obj as? String end */
                } else if let url = obj as? URL {
                    
                    if let data = try? Data.init(contentsOf: url) {
                        
                        mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: mimeType)
                    }
                    /* if let url = obj as? URL end */
                } else if let image = obj as? UIImage {
                    
                    if let data = UIImagePNGRepresentation(image) {
                        
                        mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: "image/png")
                    } else if let data = UIImageJPEGRepresentation(image, 1.0) {
                        
                        mutipartData.append(data, withName: name, fileName: "\(fileName)-\(index)", mimeType: "image/jpeg")
                    }
                } else {
                
                    self.LQLog(message: "上传的数据有误，请核对后重试！")
                }
            } /* for (index, obj) in datas.enumerated() end */
        },to: requestCharaters.0,
          method: requestCharaters.1,
          headers: headers,
          encodingCompletion: { encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                if let upR = uploadRequestHandler {
                    upR(upload)
                }
                
//                upload.responseJSON { response in
//                    switch response.result {
//                    case .success:
//                        if let value = response.result.value {
//                            let json = JSON(value)
//                            success(json)
//                        }
//                    case .failure(let error):
//                        failure(error)
//                    }
//                    }
                upload.uploadProgress(closure: { (progress) in
                    if let progressHandle = progressHandler {
                        progressHandle(progress.fractionCompleted)
                    }
                })
                
                self.handlerResponseByRequest(upload, success: success, failure: failure)
                
            case .failure(let encodingError):
                failure(encodingError)
            }
        })
    }
    
    /// 文件流读取形式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - path: 本地文件地址
    ///   - method: 请求方式
    ///   - progressHandler: 上传进度条
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    func uploadFileStream(to urlString: String,
                          filePath path: String,
                          httpMethod method: LQHTTPMethod = .post,
                          progressHandler: LQAlamoUnit_progressHandler? = nil,
                          success: @escaping LQAlamoUnit_requestSucessHandler,
                          failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest? {
        
        guard let stream = InputStream(fileAtPath: path) else {
            LQLog(message: "文件地址无效: \(path)")
            return nil
        }
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        var headers = requestCharaters.3
        headers["content-type"] = "multipart/form-data"
        
        let req = Alamofire.upload(stream, to: urlString, method: requestCharaters.1, headers: headers).uploadProgress(closure: { (progress) in
            
            if let progressHandle = progressHandler {
                
                progressHandle(progress.fractionCompleted)
                
            }
        })
        
        handlerResponseByRequest(req, success: success, failure: failure)
        
        return req
//        responseJSON { (response) in
//
//            switch response.result {
//            case .success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    success(json)
//                }
//            case .failure(let error):
//                failure(error)
//            }
//        }
    }
}

//MARK: - download Files
private extension LQAlamoUnit {
    
    /// 下载文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - parameters: 参数
    ///   - path: 下载文件保存的本地路径
    ///   - resumData: 断点续传时，已下载的文件数据
    ///   - progressHandler: 进度条回调
    ///   - successs: 成功回调
    ///   - failure: 失败回调
    func download(from urlString: String,
                  parameters: [String: String]? = nil,
                  saveTo path: String? = nil,
                  resumData: Data? = nil,
                  progressHandler: LQAlamoUnit_progressHandler? = nil,
                  successs: @escaping LQAlamoUnit_downloadSuccessHandler,
                  failure: @escaping LQAlamoUnit_downloadFailedHandler) -> LQDownloadRequest {
        
        
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
                if let progressHandle = progressHandler {
                    progressHandle(progress.fractionCompleted)
                }
        }
        
        return request
    }
    
}

// MARK: - get or post Request
private extension LQAlamoUnit {
    
    func request(urlString: String,
                 method: LQHTTPMethod,
                 params : [String : Any]? = nil,
                 success : @escaping LQAlamoUnit_requestSucessHandler,
                 failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQRequest {
        
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

        handlerResponseByRequest(dataRequest, success: success, failure: failure)
        
        return dataRequest
    }
    
    func handlerResponseByRequest(_ req: DataRequest,
                                 success : @escaping LQAlamoUnit_requestSucessHandler,
                                 failure: @escaping LQAlamoUnit_requestFailedHandler) {
        
        
        switch self.responseEncoding {
        case .json:
            req.responseJSON { (response) in
                
                switch response.result{
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        success(json)
                    }
                case .failure(let error):
//                     let err = error as NSError
//                     if err.code == NSURLErrorCancelled {
//
//                     }
                    failure(error)
                }
            }
        case .text:
            req.responseString { (response) in
                switch response.result{
                case .success:
                    if let value = response.result.value {
                        
                        success(value)
                    }
                case .failure(let error):
                    failure(error)
                }
            }
        case .plist:
            req.responsePropertyList { (response) in
                switch response.result{
                case .success:
                    if let value = response.result.value {
                        
                        success(value)
                    }
                case .failure(let error):
                    failure(error)
                }
            }
        case .data:
            req.responseData { (response) in
                switch response.result{
                case .success:
                    if let value = response.result.value {
                        
                        success(value)
                    }
                case .failure(let error):
                    failure(error)
                }
            }
        }
    }
    
    func randomString () -> String {
        
        let identifier = CFUUIDCreate(nil)
        let identifierString = CFUUIDCreateString(nil, identifier) as String
        
        return identifierString
    }
}
