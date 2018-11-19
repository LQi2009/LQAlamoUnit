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
public typealias LQAlamoUnit_requestSucessHandler = (_ response: LQResponse) -> Void
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
    ///   - timeoutInterval: 超时时间
    ///   - isCachePost: 是否缓存post请求数据
    ///   - isCacheGet: 是否缓存get请求数据
    ///   - isUseLocal: 当请求失败时，是否使用本地已缓存的数据（如果有缓存）
    public class func config(baseURL urlString: String? = nil,
                             requestEncoding req: LQRequestEncoding = .json,
                             timeoutInterval: TimeInterval = 60,
                             isCachePostResponse isCachePost: Bool = false,
                             isCacheGetResponse isCacheGet: Bool = false,
                             isUseLocalCacheWhenRequestFailed isUseLocal: Bool = false) {
        
        baseUrlString = urlString
        requestEncoding = req
        self.timeoutInterval = timeoutInterval
        self.isCacheGet = isCacheGet
        self.isCachePost = isCachePost
        self.isUseLocalCacheWhenRequestFailed = isUseLocal
    }
    
    /// 设置请求头
    ///
    /// - Parameter headers: 请求头字典
    public class func configHTTPHeaders(_ headers: [String: String]) {
        
        for (key, value) in headers {
            
            self.headers[key] = value
        }
    }
    
    /// 添加身份验证, 用于发送请求是验证身份, 相关数据会体现在请求头中
    ///
    /// - Parameters:
    ///   - user: 用户名
    ///   - password: 用户密码
    public class func configAuthenticate(withUser user: String, password: String) {
        
        self.user = user
        self.password = password
    }
    
    /// 更新基础URL
    /// 如果有多个基础URL，在发送请求时，调用此方法修改
    ///
    /// - Parameter string: 基础URL链接地址
    public class func updateBaseURLString(_ string: String) {
        
        baseUrlString = string
    }
    
    /// 请求参数的编码格式
    ///
    /// - Parameter type: 编码格式
    public class func updateRequestEncoding(_ type: LQRequestEncoding) {
        
        requestEncoding = type
    }
    
    public class func totalCachedSize() -> Double{
        
        return __totalCacheSize()
    }

    /// 清除本地已缓存的数据
    ///
    /// - Parameter maxSize: 缓存的最大数据量，单位兆(M)
    /// 当大于此值时才会清除缓存，传0则不限制，调用时就清除
    public class func clearCaches(_ maxSize: Double) {
        
        if maxSize <= 0 {
            __clearCache()
        } else {
            let cacheSize = totalCachedSize()
            if cacheSize > maxSize {
                __clearCache()
            }
        }
        
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
                          failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQRequest? {
        
        return __request(urlString: urlString,
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
                           failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQRequest? {
        
        return __request(urlString: urlString,
                                 method: .post,
                                 params: parameters,
                                 success: success,
                                 failure: failure)
    }

    /// 以URL方式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - fileURL: 本地文件URL
    ///   - method: 请求方式, 默认post
    ///   - progressHandler: 上传进度回调
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
        
        return __uploadFile(to: urlString,
                            fileURL: fileURL,
                            method: method,
                            progressHandler: progressHandler,
                            success: success,
                            failure: failure)
    }
    
    /// 一般上传文件方式，适合上传数据量不大的文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - data: 文件数据
    ///   - method: 请求方式, 默认post
    ///   - progressHandler: 上传进度条
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
        
         return __uploadData(to: urlString,
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
        
        __uploadMutipartData(to: urlString,
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
    
    
     /// 文件流读取形式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - path: 本地文件地址
    ///   - method: 请求方式
    ///   - progressHandler: 上传进度条
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    public class func uploadFileStream(to urlString: String,
                                       filePath path: String,
                                       httpMethod method: LQHTTPMethod = .post,
                                       progressHandler: LQAlamoUnit_progressHandler? = nil,
                                       success: @escaping LQAlamoUnit_requestSucessHandler,
                                       failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest? {
        
        return __uploadFileStream(to: urlString,
                                  filePath: path,
                                  httpMethod: method,
                                  progressHandler: progressHandler,
                                  success: success,
                                  failure: failure)
    }
}

//MARK: - 网络状态监控
extension LQAlamoUnit {
    
    public static var isWWANEnable: Bool {
        
        guard let rs = reachabilityManager?.isReachableOnWWAN else { return false }
        return rs
    }
    
    public static var isNetEnable: Bool {
        guard let rs = reachabilityManager?.isReachable else { return false }
        return rs
    }
    
    public static var isWifiEnable: Bool {
        
        guard let rs = reachabilityManager?.isReachableOnEthernetOrWiFi else { return false }
        return rs
    }
    
    /// 当前的网络状态
    public static var currentNetworkStatus: LQNetworkStatus {
        
        guard let rs = reachabilityManager?.networkReachabilityStatus else { return .unknown }
        
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
        
        reachabilityManager?.listener = { status in
            
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
        
        reachabilityManager?.startListening()
    }
    
    public class func stopNetworkObserver() {
        reachabilityManager?.stopListening()
    }
}

public class LQAlamoUnit {
    
    fileprivate static var baseUrlString: String?
    fileprivate static var requestEncoding: LQRequestEncoding = .json
    fileprivate static var headers: [String: String] = [:]
    
    /// 身份验证
    fileprivate static var user: String?
    fileprivate static var password: String?
    
    fileprivate static var isCacheGet: Bool = false
    fileprivate static var isCachePost: Bool = false
    fileprivate static var isUseLocalCacheWhenRequestFailed: Bool = false
    fileprivate static var timeoutInterval: TimeInterval = 60 {
        didSet{
            Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = timeoutInterval
        }
    }
    /// 网络监控
    private static var reachabilityManager = Alamofire.NetworkReachabilityManager.init()
    
    /// 将自定义类型转换为Alamofire所需的类型
    ///
    /// - Parameters:
    ///   - urlString: URL地址
    ///   - method: 请求方式
    /// - Returns: (URL, 请求方式, 请求参数编码方式, 请求头)
    fileprivate class func verifyCharacter(urlString: String,
                                           method: LQHTTPMethod)
        -> (String,
        HTTPMethod,
        ParameterEncoding,
        [String: String]) {
        
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
    
}
//MARK: - Upload Files
private extension LQAlamoUnit {
    
    /// 以URL方式上传文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - fileURL: 本地文件URL
    ///   - method: 请求方式, 默认post
    ///   - progressHandler: 上传进度回调
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    class func __uploadFile(to urlString: String,
                            fileURL: URL,
                            method: LQHTTPMethod = .post,
                            progressHandler:  LQAlamoUnit_progressHandler?,
                            success: @escaping LQAlamoUnit_requestSucessHandler,
                            failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        let req = Alamofire.upload(fileURL,
                                to: urlString,
                                method: requestCharaters.1,
                                headers: requestCharaters.3).uploadProgress { (progress) in
            
            if let progressHandle = progressHandler {
                progressHandle(progress.fractionCompleted)
            }
            }
        
        let res = LQResponse(req, requestFailedHandler: failure)
        success(res)
        return req
    }
    
    /// 一般上传文件方式，适合上传数据量不大的文件
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - data: 文件数据
    ///   - method: 请求方式, 默认post
    ///   - progressHandler: 上传进度条
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    class func __uploadData(to urlString: String,
                            data: Data,
                            method: LQHTTPMethod = .post,
                            progressHandler: LQAlamoUnit_progressHandler? = nil,
                            success: @escaping LQAlamoUnit_requestSucessHandler,
                            failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQUploadRequest {
        
        let requestCharaters = self.verifyCharacter(urlString: urlString, method: method)
        
        let req = Alamofire.upload(data,
                                   to: requestCharaters.0,
                                   method: requestCharaters.1,
                                   headers: requestCharaters.3).uploadProgress { (progress) in
            
            if let progressHandle = progressHandler {
                progressHandle(progress.fractionCompleted)
            }
        }
        
        let res = LQResponse(req, requestFailedHandler: failure)
        success(res)
        
        return req
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
    /// - Returns: 请求实例，可用于取消当前请求
    @discardableResult
    class func __uploadFileStream(to urlString: String,
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
        
        let req = Alamofire.upload(stream, to: urlString,
                                   method: requestCharaters.1,
                                   headers: headers).uploadProgress(closure: { (progress) in
            
            if let progressHandle = progressHandler {
                
                progressHandle(progress.fractionCompleted)
                
            }
        })
        
        let res = LQResponse(req, requestFailedHandler: failure)
        success(res)
        return req
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
    class func __uploadMutipartData(to urlString: String,
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
                
                upload.uploadProgress(closure: { (progress) in
                    if let progressHandle = progressHandler {
                        progressHandle(progress.fractionCompleted)
                    }
                })
                
                let res = LQResponse(upload, requestFailedHandler: failure)
                success(res)
                
            case .failure(let encodingError):
                failure(encodingError)
            }
        })
    }
    
    
}

//MARK: - download Files
extension LQAlamoUnit {
    
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
    /// - Returns: 请求实例，可用于取消当前请求
    private class func __download(from urlString: String,
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
        
        let requestCharaters = self.verifyCharacter(urlString: urlString,
                                                    method: .get)
        
        let request: DownloadRequest
        
        if let resumData = resumData {
            request = Alamofire.download(resumingWith: resumData,
                                         to: destination)
        } else {
            request = Alamofire.download(requestCharaters.0,
                                         method: requestCharaters.1,
                                         parameters: parameters,
                                         encoding: requestCharaters.2,
                                         headers: requestCharaters.3,
                                         to: destination)
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
    
    /// 一般get/post请求
    ///
    /// - Parameters:
    ///   - urlString: 网络地址
    ///   - method: 请求方式
    ///   - params: 参数
    ///   - success: 成功的回调
    ///   - failure: 失败的回调
    /// - Returns: 请求实例，可用于取消当前请求
    class func __request(urlString: String,
                         method: LQHTTPMethod,
                         params : [String : Any]? = nil,
                         success : @escaping LQAlamoUnit_requestSucessHandler,
                         failure: @escaping LQAlamoUnit_requestFailedHandler) -> LQRequest? {
        
        let netState = LQAlamoUnit.currentNetworkStatus
        if netState == .no {
            if (method == .get && isCacheGet) || (method == .post && isCachePost) {
                
                let res = LQResponse(nil, requestFailedHandler: failure, url: urlString, params: params)
                
                success(res)
                return nil
            }
        }
        
        let requestCharaters = self.verifyCharacter(urlString: urlString,
                                                    method: method)
        
        let dataRequest: DataRequest
        // 带有验证
        if let user = self.user, let psw = self.password {
            
            if let authHeader = Request.authorizationHeader(user: user, password: psw) {
                headers[authHeader.key] = authHeader.value
            }
            
            
            
            dataRequest = Alamofire.request(requestCharaters.0,
                                            method: requestCharaters.1,
                                            parameters: params,
                                            encoding: requestCharaters.2,
                                            headers: requestCharaters.3
                )
                .validate().authenticate(user: user,
                                         password: psw,
                                         persistence: URLCredential.Persistence.forSession)
        } else {
            dataRequest = Alamofire.request(requestCharaters.0,
                                            method: requestCharaters.1,
                                            parameters: params,
                                            encoding: requestCharaters.2,
                                            headers: requestCharaters.3)
                .validate()
        }

        let res = LQResponse.init(dataRequest, requestFailedHandler: failure, url: urlString, params: params)
        
        success(res)
        
        return dataRequest
    }
    
    class func randomString () -> String {
        
        let identifier = CFUUIDCreate(nil)
        let identifierString = CFUUIDCreateString(nil, identifier) as String
        
        return identifierString
    }
    
    class func LQLog<T>(message: T,
                        file: String = #file,
                        method: String = #function,
                        line: Int = #line)
    {
        #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        #endif
    }
}


public struct LQResponse {
    
    private var req: DataRequest?
    private var requestFailedHandler : LQAlamoUnit_requestFailedHandler?
    
    private var urlString : String?
    private var params : [String: Any]?
    
    init(_ obj: DataRequest?, requestFailedHandler : LQAlamoUnit_requestFailedHandler?, url: String? = nil, params: [String: Any]? = nil) {
        self.req = obj
        self.requestFailedHandler = requestFailedHandler
        self.urlString = url
        self.params = params
    }
    
    public func responseJSON(_ handler: @escaping (_ obj: JSON) -> Void) {
        
        guard req != nil else {
            
            if let url = urlString {
                if let res = LQAlamoUnit.cacheResponseOf(url, params: params) {
                    
                    let json = JSON(res)
                    handler(json)
                }
            }
            
            return
        }
        
        req?.responseJSON { (response) in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    handler(json)
                    self.cacheResponse(value)
                } else {
                    handler("Request success, but none data response")
                }
                
            case .failure(let error):
                //                     let err = error as NSError
                //                     if err.code == NSURLErrorCancelled {
                //
                //                     }
                
                if LQAlamoUnit.isUseLocalCacheWhenRequestFailed && (LQAlamoUnit.isCachePost || LQAlamoUnit.isCacheGet) {
                    if let url = self.urlString, let obj = LQAlamoUnit.cacheResponseOf(url, params: self.params) {
                        let json = JSON(obj)
                        handler(json)
                    } else {
                        self.requestFailedHandler?(error)
                    }
                } else {
                    self.requestFailedHandler?(error)
                }
            }
        }
    }
    
    public func responseText(_ handler: @escaping (_ obj: String?) -> Void) {
        
        guard req != nil else {
            
            if let url = urlString {
                if let res = LQAlamoUnit.cacheResponseOf(url, params: params) as? String {
                    
                    handler(res)
                }
            }
            
            return
        }
        
        req?.responseString { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    
                    handler(value)
                    self.cacheResponse(value)
                } else {
                    handler(nil)
                }
            case .failure(let error):
                
                if LQAlamoUnit.isUseLocalCacheWhenRequestFailed && (LQAlamoUnit.isCachePost || LQAlamoUnit.isCacheGet) {
                    if let url = self.urlString, let obj = LQAlamoUnit.cacheResponseOf(url, params: self.params) as? String {
                        
                        handler(obj)
                    } else {
                        self.requestFailedHandler?(error)
                    }
                } else {
                    self.requestFailedHandler?(error)
                }
            }
        }
    }
    
    public func responseList(_ handler: @escaping (_ obj: Any?) -> Void) {
        
        guard req != nil else {
            
            if let url = urlString {
                if let res = LQAlamoUnit.cacheResponseOf(url, params: params) {
                    
                    handler(res)
                }
            }
            
            return
        }
        
        req?.responsePropertyList { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    
                    handler(value)
                    self.cacheResponse(value)
                } else {
                    handler(nil)
                }
            case .failure(let error):
                if LQAlamoUnit.isUseLocalCacheWhenRequestFailed && (LQAlamoUnit.isCachePost || LQAlamoUnit.isCacheGet) {
                    if let url = self.urlString, let obj = LQAlamoUnit.cacheResponseOf(url, params: self.params) {
                        
                        handler(obj)
                    } else {
                        self.requestFailedHandler?(error)
                    }
                } else {
                    self.requestFailedHandler?(error)
                }
            }
        }
    }
    
    public func responseData(_ handler: @escaping (_ obj: Data?) -> Void) {
        
        guard req != nil else {
            
            if let url = urlString {
                if let res = LQAlamoUnit.cacheResponseOf(url, params: params) as? Data {
                    
                    handler(res)
                }
            }
            
            return
        }
        
        req?.responseData { (response) in
            switch response.result{
            case .success:
                if let value = response.result.value {
                    
                    handler(value)
                    self.cacheResponse(value)
                } else {
                    
                }
            case .failure(let error):
                
                if LQAlamoUnit.isUseLocalCacheWhenRequestFailed && (LQAlamoUnit.isCachePost || LQAlamoUnit.isCacheGet) {
                    if let url = self.urlString, let obj = LQAlamoUnit.cacheResponseOf(url, params: self.params) as? Data {
                        
                        handler(obj)
                    } else {
                        self.requestFailedHandler?(error)
                    }
                } else {
                    self.requestFailedHandler?(error)
                }
            }
        }
    }
    
    public func response(_ handler: @escaping (_ obj: Data?) -> Void) {
        
        guard req != nil else {
            
            if let url = urlString {
                if let res = LQAlamoUnit.cacheResponseOf(url, params: params) as? Data {
                    
                    handler(res)
                }
            }
            
            return
        }
        
        req?.response(completionHandler: { (response) in
            
            if let error = response.error {
                
                if LQAlamoUnit.isUseLocalCacheWhenRequestFailed && (LQAlamoUnit.isCachePost || LQAlamoUnit.isCacheGet) {
                    if let url = self.urlString, let obj = LQAlamoUnit.cacheResponseOf(url, params: self.params) as? Data {
                        
                        handler(obj)
                    } else {
                        self.requestFailedHandler?(error)
                    }
                } else {
                    self.requestFailedHandler?(error)
                }
                
            } else {
                self.cacheResponse(response.data)
                handler(response.data)
            }
        })
    }
    
    private func cacheResponse(_ obj: Any?) {
        
        guard let url = urlString else { return }
        
        if (LQAlamoUnit.isCachePost) || ( LQAlamoUnit.isCacheGet) {
            
            LQAlamoUnit.cacheResponseObj(obj, url: url, params: params)
        }
    }
}



private extension LQAlamoUnit {
    
    class func __clearCache() {
        
        let path = cachePath()
        let fm = FileManager.default
        if fm.fileExists(atPath: path) {
            try? fm.removeItem(atPath: path)
        }
    }
    
    class func __totalCacheSize() -> Double {
        
        let dirPath = cachePath()
        let fm = FileManager.default
        
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: dirPath, isDirectory: &isDir) {
            
            if isDir.boolValue {
                
                guard let paths = try? fm.contentsOfDirectory(atPath: dirPath) else {return 0 }
                
                var total: Double = 0
                
                for subPath in paths {
                    let path = dirPath + "/" + subPath

                    if let info = try? fm.attributesOfItem(atPath: path) {
                        if let size = info[FileAttributeKey.size] as? Double {
                            
                            total += size
                        }
                    }
                }
                
                return total / (1024.0 * 1024.0)
            }
        }
        
        return 0
    }
    
    class func cachePath() -> String {
        
        return NSHomeDirectory() + "/Documents/LQAlamoUnitCaches"
    }
    
    class func absoluteUrlWithPath(_ path: String) -> String {
        if path.count == 0 {
            
            guard let base = baseUrlString else {return ""}
            guard base.count > 0 else {return ""}
            
            return base
        }
        
        guard let base = baseUrlString else { return path }
        guard base.count > 0 else { return path }
        
        var absoluteUrl = path
        
        if path.hasPrefix("http://") == false && path.hasPrefix("https://") == false {
            
            if base.hasSuffix("/") {
                if path.hasPrefix("/") {
                    absoluteUrl.removeFirst()
                    absoluteUrl = base + absoluteUrl
                } else {
                    absoluteUrl = base + absoluteUrl
                }
            } else {
                if path.hasPrefix("/") {
                    absoluteUrl = base + absoluteUrl
                } else {
                    absoluteUrl = base + "/" + absoluteUrl
                }
            }
        }
        
        return absoluteUrl
    }
    
    class func uniqueFileName(_ url: String, params: [String: Any]?) -> String {
        
        var url = url
        
        if url.hasPrefix("http") == false {
            if let ul = baseUrlString {
                url = ul + url
            }
        }
        
        guard let param = params else { return url.md5 }
        
        if param.count <= 0 {
            return url.md5
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) {
            
            if let str = String(data: data, encoding: .utf8) {
                var unique = url + str
                //                unique = unique.trimmingCharacters(in: .whitespacesAndNewlines)
                
                unique = unique.replacingOccurrences(of: " ", with: "")
                unique = unique.replacingOccurrences(of: "\n", with: "")
                
                LQLog(message: unique)
                //                LQLog(message: s)
                return unique.md5
            }
        }
        
        var unique = url
        
        for (key, value) in param {
            
            if value is Dictionary<String, Any> {
                continue
            } else if value is Array<Any> {
                continue
            }
            
            unique += unique + key + "\(value)"
        }
        
        return unique.md5
    }
    
    class func cacheResponseObj(_ obj: Any?, url: String, params: [String: Any]?) {
        
        guard let obj = obj else { return }
        
        if url.count > 0 {
            
            let path = cachePath()
            let fm = FileManager.default
            
            if fm.fileExists(atPath: path) == false {
                
                do {
                    try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    
                    LQLog(message: error)
                    return
                }
            }
            
            let key = uniqueFileName(url, params: params)
            let filePath = path + "/" + key
            var data: Data?
            
            if let dt = obj as? Data {
                data = dt
            } else {
                
                if JSONSerialization.isValidJSONObject(obj) {
                    if let dt = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) {
                        data = dt
                    }
                } else if let text = obj as? String {
                    
                    if let dt = Data(base64Encoded: text) {
                        data = dt
                    }
                }
                
            }
            
            if let dt = data {
                
                let ok = fm.createFile(atPath: filePath, contents: dt, attributes: nil)
                
                if ok {
                    LQLog(message: "cache file for \(url)/n filePath: \(filePath)")
                }
            }
        }
    }
    
    class func cacheResponseOf(_ url: String, params: [String: Any]?) -> Any? {
        
        guard url.count > 0 else {
            return nil
        }
        
        let path = cachePath()
        let key = uniqueFileName(url, params: params)
        let filePath = path + "/" + key
        
        return FileManager.default.contents(atPath: filePath)
    }
}

private extension String {
    
    var md5: String {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        return String(format: hash as String)
    }
}
