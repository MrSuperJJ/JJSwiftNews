//
//  Protocols.swift
//  JJSwiftNews
//
//  Created by Mr.JJ on 2017/7/29.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import RxSwift

protocol NewsType {
    /// 资讯标题
    var title: String { get }
    /// 资讯图片连接
    var imageLink: String { get }
    /// 是否纯文本资讯
    var isPure: Bool { get }
    /// 资讯唯一标识
    var uniquekey: String { get }
    /// 资讯来源
    var authorName: String { get }
    /// 资讯链接
    var url: String { get }
}

/// Banner协议
protocol BannerModelType: NewsType { }

/// 资讯协议
protocol NewsModelType: NewsType { }

typealias NewsDataResultObservable = Observable<([BannerModelType], [NewsModelType])>

protocol NewsService {
    func requestNewsData(of newsType: String) -> NewsDataResultObservable
}
