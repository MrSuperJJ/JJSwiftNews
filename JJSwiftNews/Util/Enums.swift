//
//  Enums.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/8.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation

enum RxSwiftMoyaResult {
    case success(([BannerModelType], [NewsModelType]))
    case failure(Error)
}

enum RxSwiftMoyaError: Error {
    case networkError
    case jsonFormatError
    case jsonParsedError
    case noResultError(String)
    case noMoreDataError
    case requetFailedError
}

enum NewsFetchResult {
    case success((Int, [SectionOfNews]))
    case failure((Int, NewsFetchError))
}

enum NewsFetchError: Error {
    case networkError
    case jsonFormatError
    case jsonParsedError
    case noResultError(String)
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
            case .noResultError(let msg):
                return msg
            case .noMoreDataError:
                return "数据异常"
            case .requetFailedError:
                return "访问异常"
            }
        }
    }
}

extension NewsFetchError {

    init(_ error: Error) {
        switch error {
        case RxSwiftMoyaError.networkError:
            self = .networkError
        case RxSwiftMoyaError.jsonFormatError:
            self = .jsonFormatError
        case RxSwiftMoyaError.jsonParsedError:
            self = .jsonParsedError
        case RxSwiftMoyaError.noResultError(let msg):
            self = .noResultError(msg)
        case RxSwiftMoyaError.noMoreDataError:
            self = .noMoreDataError
        case RxSwiftMoyaError.requetFailedError:
            self = .requetFailedError
        default:
            self = .requetFailedError
        }
    }
}
