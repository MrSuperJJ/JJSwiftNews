//
//  JJBannerModel.swift
//  JJSwiftNews
//
//  Created by Mr.JJ on 2017/7/30.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import SwiftyJSON

struct JJBannerModel: JJNewsModelType {

    /// banner标题
    let title: String
    /// banner图片连接
    let imageLink: String

    init(_ bannerJSON: JSON) {
        title = bannerJSON["title"].stringValue
        imageLink = bannerJSON["thumbnail_pic_s"].stringValue
    }
}
