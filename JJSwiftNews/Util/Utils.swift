//
//  Utils.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/15.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import Alamofire

struct NetworkUtil {
    
    static var isNetworkReachable: Bool {
        get {
            guard NetworkReachabilityManager(host: "www.baidu.com")?.isReachable == true else {
                return false
            }
            return true
        }
    }
}
