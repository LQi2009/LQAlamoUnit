# LDAlamoUnit

基于Alamofire/SwiftyJSON的网络请求封装

# 说明
简单封装了Get与Post请求, 并使用SwiftyJSON来解析数据:

```Swift
enum LDHTTPType {
    case Get, Post
}
```

这里只设置了请求参数的编码格式:

```Swift
enum LDRequestEncoding {
    case Json, Text, Plist
}
```

关于返回数据的格式, 可以直接调用不同的response方法来使用不同的编码结果, 这里使用的是json.

这里所有的属性和实例方法都是私有的, 对我公开的全部是类方法, 方便使用的调用.

一些配置的方法, 调用一次即可, 不用每次发请求的时候都调用, 例如:
```Swift

class func setBaseURLString(_ string: String)
class func setRequestEncoding(_ type: LDRequestEncoding)
class func setHTTPHeaders(_ headers: [String: String])
...
```

# 使用

使用的时候, 可全局一次性配置一些参数设置信息, 只需要设置一次:
```Swift
LDAlamoUnit.setRequestEncoding(.Text)
LDAlamoUnit.setBaseURLString("urlBaseString")
LDAlamoUnit.setHTTPHeaders(["header": "value"])
```

发送Post请求:

```Swift
        LDAlamoUnit.post("http://testuser.artup.com/artup-user-api/f/login", parameters: ["mobile": "18310246496", "pwd": "123456"], success: { (json) in
            
            print(json)
        }) { (error) in
            print(error)
        }

```

发送Get请求:

```Swift
LDAlamoUnit.get("http://testuser.artup.com/artup-user-api/f/login", parameters: ["mobile": "18310246496", "pwd": "123456"], success: { (json) in
            print(json)
        }) { (error) in
            print(error)
        }

```
其他接口, 可直接查看//MARK: - Public Method部分的extension分类的方法及注释.
