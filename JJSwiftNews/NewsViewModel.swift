//
//  NewsViewModel.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/6.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation

struct NewsViewModel {
    
    let newsService: NewsService
    
    init(newsService: NewsService) {
        self.newsService = newsService
    }
    
    internal func requestNewsData(of type: String) {
        newsService.requestNewsData(of: type) { (newsDataArray) in
            printLog(newsDataArray)
        }
    }
}
