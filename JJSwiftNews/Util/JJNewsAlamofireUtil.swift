//
//  JJNewsAlamofireUtil.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/7/31.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct JJNewsAlamofireUtil {
    // MARK: 请求数据
    static func requestData(type: String, completionHandler: ((JSON?, JJError?) -> Void)?) {
        guard NetworkReachabilityManager(host: "www.baidu.com")?.isReachable == true else {
            if let completionHandler = completionHandler {
                completionHandler(nil, JJError.networkError)
            }
            return
        }
        let requestURL = "http://toutiao-ali.juheapi.com/toutiao/index"
        let headers = ["Authorization": "APPCODE fd4e0a674e274e46ad3e26ab508ff21c", "type": type]
        let method = HTTPMethod.get
        let parameters = ["type": type]
        
        Alamofire.request(requestURL, method: method, parameters: parameters, headers: headers).response(completionHandler: { (response) in
            let contentJSON = JSON(data: response.data!)["result"]
            if let completionHandler = completionHandler {
                // 检查数据一致性，用topic_id作为判断依据，防止多次快速请求
                if let requestHeaders = response.request?.allHTTPHeaderFields {
                    if let type = requestHeaders["type"] {
                        if currTopicType != type {
                            completionHandler(nil, JJError.dataInconsistentError)
                            return
                        }
                    }
                }
                contentJSON["stat"].intValue == 1 ? completionHandler(contentJSON["data"], nil) : completionHandler(nil, JJError.requetFailedError(contentJSON["msg"].stringValue))
            }
        })
    }
}
