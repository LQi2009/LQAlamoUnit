# LQAlamoUnit

基于Alamofire/SwiftyJSON的网络请求封装

# 安装
##### 手动
将 LQAlamoUnit 文件夹内文件直接拖入项目即可，同时需要添加Alamofire/SwiftyJSON

##### Cocoapos
在Podfile文件中添加
```
pod 'LQAlamoUnit', '~> 1.1.0'
```

执行 pod install 即可！

# 使用
简单封装了get与post请求, 并使用SwiftyJSON来解析数据:

```Swift
/// 网络请求方式
///
/// - get: get
/// - post: post
enum LQRequestType {
    case get, post
}
```

这里只设置了请求参数的编码格式(返回数据格式统一为json):

```Swift
/// 网络请求参数编码方式
///
/// - json: json
/// - text: text
/// - plist: plist属性列表
enum LQRequestEncoding {
    case json, text, plist
}
```

关于返回数据的格式, 可以直接调用不同的response方法来使用不同的编码结果, 这里使用的是json.

这里所有的属性和实例方法都是私有的, 对外公开的全部是类方法, 方便使用的调用.

一些配置的方法, 调用一次即可, 不用每次发请求的时候都调用, 例如:
```Swift

    /// 基础URL
    ///
    /// - Parameter string: 基础URL链接地址
    class func setBaseURLString(_ string: String)
    /// 请求参数的编码格式
    ///
    /// - Parameter type: 编码格式
    class func setRequestEncoding(_ type: LQRequestEncoding)
    /// 请求头
    ///
    /// - Parameter headers: 请求头字典
    class func setHTTPHeaders(_ headers: [String: String])
...
```

# 使用
### 发送请求
使用的时候, 可全局一次性配置一些参数设置信息, 只需要设置一次:
```Swift
LQAlamoUnit.setRequestEncoding(.text)
LQAlamoUnit.setBaseURLString("urlBaseString")
LQAlamoUnit.setHTTPHeaders(["header": "value"])
```

发送Post请求:

```Swift
        LQAlamoUnit.post("http://", parameters: ["mobile": "23345", "pwd": "123456"], success: { (json) in
            
            print(json)
        }) { (error) in
            print(error)
        }

```

发送Get请求:

```Swift
LQAlamoUnit.get("http://", parameters: ["mobile": "23456", "pwd": "123456"], success: { (json) in
            print(json)
        }) { (error) in
            print(error)
        }

```

### 监听网络状态
```

LQAlamoUnit.startNetworkObserver { (state) in
            print(state)
}
```
获取当前网络状态
```

print(LQAlamoUnit.currentNetworkStatus)
```
        

其他接口, 可直接查看//MARK: - Public Method部分的extension分类的方法及注释.
