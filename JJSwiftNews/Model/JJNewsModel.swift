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

    /// 资讯标题
    let title: String
    /// 资讯图片连接
    let imageLink: String
    /// 是否纯文本资讯
    let isPure: Bool
    /// 唯一标识
    let uniquekey: String
    /// 资讯来源
    let authorName: String
    
    init(_ newsJSON: JSON) {
        title = newsJSON["title"].stringValue
        imageLink = newsJSON["thumbnail_pic_s"].stringValue
        isPure = newsJSON["ispure"].boolValue
        uniquekey = newsJSON["uniquekey"].stringValue
        authorName = newsJSON["author_name"].stringValue
    }
}
