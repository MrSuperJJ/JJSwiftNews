//
//  File.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/8.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation
import RxDataSources

struct SectionOfNews {
    var items: [Item]
}

extension SectionOfNews: SectionModelType {
    typealias Item = Any
    
    init(original: SectionOfNews, items: [Item]) {
        self = original
        self.items = items
    }
}
