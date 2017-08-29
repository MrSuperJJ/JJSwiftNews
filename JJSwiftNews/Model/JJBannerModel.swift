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
