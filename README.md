# LQAlamoUnit

基于Alamofire/SwiftyJSON的网络请求封装

# 安装
##### 手动
将 LQAlamoUnit 文件夹内文件直接拖入项目即可，同时需要添加Alamofire/SwiftyJSON

##### Cocoapos
在Podfile文件中添加
```
pod 'LQAlamoUnit', '~> 1.5.2'
```

执行 pod install 即可！


# 版本说明

- 1.5.2
此版本统一返回数据格式为解析后的JSON，直接添加以下代码即可：
```
pod 'LQAlamoUnit', '~> 1.5.1'
```

例如：
```
LQAlamoUnit.post("http://host/forward/getStyleList", parameters: ["loginId": "1ce1c2469241ddb9e6", "storeId": "81"], success: { (json) in
            print(json)
        }) { (error) in
            print(error)
        }
        
```

- 1.6.0
此版本定义了一个返回值的实例 **LQResponse** ，用于获取不同格式化的返回值类型；
一开始返回值定义为Any，但是在使用的时候很不方便，且导致内部的不同类型获取变得毫无意义，最终使用这种方式来解决，导致在使用时多了一层闭包嵌套，如果有更好的方法，还请赐教：
```swfit
LQAlamoUnit.post("http://host/forward/getStyleList", parameters: ["loginId": "1ce1c2469e92db9e6", "storeId": "88"], success: { (res) in
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
```

- 1.7.0 
此版本在1.5.2基础上增加了post/get接口返回数据缓存，这里返回的数据格式统一为JSON，使用方式一样，调用以下方法来设置是否缓存
```Swift
LQAlamoUnit.config(isCachePostResponse: true, isCacheGetResponse: true, isUseLocalCacheWhenRequestFailed: true)
```

不过，需要建立桥接文件，并引入头文件
```
#import <CommonCrypto/CommonCrypto.h>
```

- 1.8.0

此版本在1.6.0基础上增加了post/get接口返回数据缓存
调用以下方法来设置是否缓存

```Swift
LQAlamoUnit.config(isCachePostResponse: true, isCacheGetResponse: true, isUseLocalCacheWhenRequestFailed: true)
```
同样需要建立桥接文件，并引入头文件
```
#import <CommonCrypto/CommonCrypto.h>
```

可根据具体情况使用相应的版本



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
