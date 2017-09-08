//
//  Extensions.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/8.
//  Copyright © 2017年  . All rights reserved.
//

import Foundation

private let viewTagOffset = 1000

extension Int {
    
    var tagByAddingOffset: Int {
        return self + viewTagOffset
    }
    
    var indexByRemovingOffset: Int {
        return self - viewTagOffset
    }
}
