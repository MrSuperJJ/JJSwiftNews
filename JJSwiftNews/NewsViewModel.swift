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
    let currentTopicTypeChanged: Observable<[NewsDataModel]>

    init(input currentTopicType: Observable<String>, dependency newsService: NewsService) {
        self.newsService = newsService
        currentTopicTypeChanged = currentTopicType.flatMapLatest { type in
            return newsService.requestNewsData(of: type).observeOn(MainScheduler.instance)
        }
    }
}
