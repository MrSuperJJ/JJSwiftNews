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

    init(newsModel: NewsModelType) {
        newsTitle = newsModel.title
        newsImageLink = newsModel.imageLink
        newsIsPure = newsModel.isPure
        newsUniquekey = newsModel.uniquekey
        newsAuthorName = newsModel.authorName
        newsUrl = newsModel.url
    }
}
