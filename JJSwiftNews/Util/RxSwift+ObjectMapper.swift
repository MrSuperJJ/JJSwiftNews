//
//  RxSwift&ObjectMapper.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/6.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

// MARK: - JSON -> Model
extension Observable {
    func mapObject<T: BaseMappable>(type: T.Type) -> Observable<T> {
        return self.map { response in
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.JSONFormatError
            }
            guard let observable = Mapper<T>().map(JSON: dict) else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            return observable
        }
    }
}

enum RxSwiftMoyaError: String {
    case JSONFormatError
    case ParseJSONError
    case OtherError
}

extension RxSwiftMoyaError: Swift.Error { }
