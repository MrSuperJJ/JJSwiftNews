//
//  JJBannerModel.swift
//  JJSwiftNews
//
//  Created by Mr.JJ on 2017/7/30.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import SwiftyJSON

struct JJBannerModel: JJNewsModelType, JJBannerModelType {

    var title: String {
        return newsTitle
    }

    var imageLink: String {
        return newsImageLink
    }

    var isPure: Bool {
        return isNewsPure
    }

    var uniquekey: String {
        return newsUniquekey
    }

    var authorName: String {
        return newsAuthorName
    }

    var url: String {
        return newsURL
    }

    private let newsTitle: String
    private let newsImageLink: String
    private let isNewsPure: Bool
    private let newsUniquekey: String
    private let newsAuthorName: String
    private let newsURL: String

    init(_ newsJSON: JSON) {
        newsTitle = newsJSON["title"].stringValue
        newsImageLink = newsJSON["thumbnail_pic_s"].stringValue
        isNewsPure = newsJSON["ispure"].boolValue
        newsUniquekey = newsJSON["uniquekey"].stringValue
        newsAuthorName = newsJSON["author_name"].stringValue
        newsURL = newsJSON["url"].stringValue
    }
}
