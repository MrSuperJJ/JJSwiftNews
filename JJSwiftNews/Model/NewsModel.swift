//
//  JJNewsModel.swift
//  JJSwiftNews
//
//  Created by Mr.JJ on 2017/7/29.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

struct NewsModel: NewsModelType {

    var title: String {
        return newsJSON["title"].stringValue
    }

    var imageLink: String {
        return newsJSON["thumbnail_pic_s"].stringValue
    }

    var isPure: Bool {
//        return newsJSON["ispure"].boolValue
        return isPureNews
    }

    var uniquekey: String {
        return newsJSON["uniquekey"].stringValue
    }

    var authorName: String {
        return newsJSON["author_name"].stringValue
    }

    var url: String {
        return newsJSON["url"].stringValue
    }

    private let newsJSON: JSON
    private let isPureNews: Bool

    init(_ newsJSON: JSON) {
        self.newsJSON = newsJSON
        /// 随机数控制是否是纯文本资讯
        isPureNews = Int.random(0...10) % 2 == 0 ? true : false
    }
}

struct NewsDataModel: NewsModelType, ImmutableMappable {

    var title: String {
        return newsTitle
    }
    
    var imageLink: String {
        return newsImageLink
    }
    
    var isPure: Bool {
        return newsIsPure
    }
    
    var uniquekey: String {
        return newsUniquekey
    }
    
    var authorName: String {
        return newsAuthorName
    }
    
    var url: String {
        return newsUrl
    }
    
    private let newsTitle: String
    private let newsImageLink: String
    private let newsIsPure: Bool
    private let newsUniquekey: String
    private let newsAuthorName: String
    private let newsUrl: String
    
    init(map: Map) throws {
        newsTitle = try map.value("title")
        newsImageLink = try map.value("thumbnail_pic_s")
        newsIsPure = Int.random(0...10) % 2 == 0 ? true : false
        newsUniquekey = try map.value("uniquekey")
        newsAuthorName = try map.value("author_name")
        newsUrl = try map.value("url")
    }

}

struct NewsDataResult: ImmutableMappable {
    
    let state: String
    let newsDataArray: [NewsDataModel]
    
    init(map: Map) throws {
        state = try map.value("stat")
        newsDataArray = try map.value("data")
    }
}

struct NewsResponseData: ImmutableMappable {
    
    let reason: String
    let result: NewsDataResult
    
    init(map: Map) throws {
        reason = try map.value("reason")
        result = try map.value("result")
    }
}
