//
//  NewsDataMoyaService.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/6.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import ObjectMapper

struct NewsMoyaService: NewsService {
    
    static let defaultService = NewsMoyaService()
    
    private let provider: RxMoyaProvider<NewsRequestType>

    init() {
        // 解决URL地址中存在?时编码错误的问题
        let endpointClosure = { (target: NewsRequestType) -> Endpoint<NewsRequestType> in
//            print("baseURL:\(target.baseURL)\n path:\(target.path)")
            let url = target.baseURL.absoluteString + target.path
            let endpoint = Endpoint<NewsRequestType>(url: url, sampleResponseClosure: { .networkResponse(200, target.sampleData) }, method: target.method, parameters: target.parameters, parameterEncoding: target.parameterEncoding, httpHeaderFields: target.headers)
            return endpoint.adding(newHTTPHeaderFields: [:])
        }
        provider = RxMoyaProvider<NewsRequestType>(endpointClosure: endpointClosure)
    }

    func requestNewsData(of newsType: String) -> Observable<[NewsDataModel]> {
        return provider.request(.requestData(newsType: newsType)).mapJSON(failsOnEmptyData: true).mapObject(type: NewsResponseData.self).map {
            return $0.result!.newsDataArray!
        }
    }

}

// MARK: - Request Configuration of Moya
private enum NewsRequestType {
    case requestData(newsType: String)
}

extension NewsRequestType: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://toutiao-ali.juheapi.com")!
    }
    
    var path: String {
        switch self {
        case .requestData:
            return "/toutiao/index"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .requestData:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .requestData(let newsType):
            return ["type": newsType]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .request
    }
    
    var headers: [String: String]? {
        switch self {
        case .requestData(let newsType):
            return ["Authorization": "APPCODE fd4e0a674e274e46ad3e26ab508ff21c", "type": newsType]
        }
    }
}



