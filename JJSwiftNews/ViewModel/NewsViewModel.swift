//
//  NewsViewModel.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/6.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct NewsViewModel {
    
    private let newsService: NewsService
    let newsContentReloadFinished: NewsDataResultObservable
    let newsContentLoadMoreFinished: NewsDataResultObservable

    init(input: (currTopicType: Observable<String>, lastTopicType: Observable<String>), dependency newsService: NewsService) {
        self.newsService = newsService
        newsContentReloadFinished = input.currTopicType.flatMapLatest { type in
            return newsService.requestNewsData(of: type)
        }
        newsContentLoadMoreFinished = input.lastTopicType.flatMapLatest { type in
            return newsService.requestNewsData(of: type)
        }
    }
}
