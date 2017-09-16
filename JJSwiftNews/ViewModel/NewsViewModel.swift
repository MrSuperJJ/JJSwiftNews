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
    
    internal let newsTopicNameArray: Observable<[String]>
    internal let newsContentReloadFinished: Observable<NewsFetchResult>
    internal let newsContentLoadMoreFinished:  Observable<NewsFetchResult>

    /// 初始化
    ///
    /// - Parameters:
    ///   - currContentReLoadIndex: 当前主题对应的资讯索引
    ///   - currContentLoadMoreIndex: 当前主题加载更多时用的索引
    init(currContentReLoadIndex: Observable<Int>, currContentLoadMoreIndex: Observable<Int>) {
        let topicService = NewsTopicSerivce.defaultService
        let newsService = NewsMoyaService.defaultService
        
        newsTopicNameArray = Observable.just(topicService.topicNameArray())
        let newsContentReload = currContentReLoadIndex.map({
            return topicService.topicType(of: $0)
        }).flatMapLatest { type -> Observable<RxSwiftMoyaResult> in
            guard NetworkUtil.isNetworkReachable else {
                return Observable.of(RxSwiftMoyaResult.failure(RxSwiftMoyaError.networkError))
            }
            return newsService.requestNewsData(of: type)
        }
        let newsContentLoadMore = currContentLoadMoreIndex.map({
            return topicService.topicType(of: $0)
        }).flatMapLatest { type -> Observable<RxSwiftMoyaResult> in
            guard NetworkUtil.isNetworkReachable else {
                return Observable.of(RxSwiftMoyaResult.failure(RxSwiftMoyaError.networkError))
            }
            return newsService.requestNewsData(of: type)
        }
        newsContentReloadFinished = Observable.zip(currContentReLoadIndex.asObservable(), newsContentReload.asObservable(), resultSelector: { (index, result) in
            switch result {
            case .success(let tuple):
                return NewsFetchResult.success((index, [SectionOfNews(items: [tuple.0]), SectionOfNews(items: tuple.1)]))
            case .failure(let error):
                return NewsFetchResult.failure((index, NewsFetchError(error)))
            }
        })
        newsContentLoadMoreFinished = Observable.zip(currContentLoadMoreIndex.asObservable(), newsContentLoadMore.asObservable(), resultSelector: { (index, result) in
            switch result {
            case .success(let tuple):
                return NewsFetchResult.success((index, [SectionOfNews(items: [tuple.0]), SectionOfNews(items: tuple.1)]))
            case .failure(let error):
                return NewsFetchResult.failure((index, NewsFetchError(error)))
            }
        })
    }
}
