//
//  Extensions.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/8.
//  Copyright © 2017年  . All rights reserved.
//

import Foundation

// MARK: - JSON -> Model
import RxSwift
import ObjectMapper

extension Observable {
    func mapObject<T: BaseMappable>(type: T.Type) -> Observable<T>  {
        return self.map { response in
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.jsonFormatError
            }
            guard let observable = Mapper<T>().map(JSON: dict) else {
                throw RxSwiftMoyaError.jsonParsedError
            }
            return observable
        }
    }
}

// MARK: - Int
private let viewTagOffset = 1000

extension Int {
    
    var tagByAddingOffset: Int {
        return self + viewTagOffset
    }
    
    var indexByRemovingOffset: Int {
        return self - viewTagOffset
    }
}
