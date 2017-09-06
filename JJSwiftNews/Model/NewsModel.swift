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

struct NewsDataModel: NewsModelType, Mappable {

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
    
    private var newsTitle: String!
    private var newsImageLink: String!
    private var newsIsPure: Bool!
    private var newsUniquekey: String!
    private var newsAuthorName: String!
    private var newsUrl: String!

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        newsTitle <- map["title"]
        newsImageLink <- map["thumbnail_pic_s"]
        newsIsPure = Int.random(0...10) % 2 == 0 ? true : false
        newsUniquekey <- map["uniquekey"]
        newsAuthorName <- map["author_name"]
        newsUrl <- map["url"]
    }
}

struct NewsDataResult: Mappable {
    
    var state: String!
    var newsDataArray: [NewsDataModel]!

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        state <- map["stat"]
        newsDataArray <- map["data"]
    }
}

struct NewsResponseData: Mappable {
    
    var reason: String!
    var result: NewsDataResult!

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        reason <- map["reason"]
        result <- map["result"]
    }
}
