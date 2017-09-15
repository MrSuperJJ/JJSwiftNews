//
//  Enums.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/8.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation

enum NewsFetchResult {
    case success(newsResult: NewsModelType)
    case failed(error: NewsFetchError)
}

enum NewsFetchError: Error {
    case networkError
    case jsonFormatError
    case jsonParsedError
    case noMoreDataError
    case requetFailedError
    
    internal var description: String {
        get {
            switch self {
            case .networkError:
                return "网络似乎不给力"
            case .jsonFormatError:
                return "JSON格式错误"
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
