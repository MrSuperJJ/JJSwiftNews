//
//  JJError.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/7/31.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation

enum JJError: Error {
    case networkError
    case dataInconsistentError
    case jsonParsedError
    case noMoreDataError(String)
    case requetFailedError(String)
    
    internal var description: String {
        get {
            switch self {
            case .networkError:
                return "网络似乎不给力"
            case .dataInconsistentError:
                return "数据不一致"
            case .jsonParsedError:
                return "JSON解析错误"
            case .noMoreDataError:
                return "数据异常"
            case .requetFailedError:
                return "访问异常"
            }
        }
    }
}
