//
//  JJNewsModel.swift
//  JJSwiftNews
//
//  Created by Mr.JJ on 2017/7/29.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import SwiftyJSON

struct JJNewsModel: JJNewsModelType {

    var title: String {
        return newsJSON["title"].stringValue
    }

    var imageLink: String {
        return newsJSON["thumbnail_pic_s"].stringValue
    }

    var isPure: Bool {
//        return newsJSON["ispure"].boolValue
        /// 随机数控制是否是纯文本资讯
        return Int.random(0...10) % 2 == 0 ? true : false
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

    init(_ newsJSON: JSON) {
        self.newsJSON = newsJSON
    }
}
