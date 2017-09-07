//
//  BannerModel.swift
//  JJSwiftNews
//
//  Created by Mr.JJ on 2017/7/30.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation

struct BannerModel: BannerModelType {

    var title: String {
        return newsTitle
    }
    
    var imageLink: String {
        return newsImageLink
    }
    
    var uniquekey: String {
        return newsUniquekey
    }
    
    var url: String {
        return newsUrl
    }
    
    private var newsTitle: String!
    private var newsImageLink: String!
    private var newsUrl: String!
    private var newsUniquekey: String!

    init(newsModel: NewsModelType) {
        newsTitle = newsModel.title
        newsImageLink = newsModel.imageLink
        newsUniquekey = newsModel.uniquekey
        newsUrl = newsModel.url
    }
}
