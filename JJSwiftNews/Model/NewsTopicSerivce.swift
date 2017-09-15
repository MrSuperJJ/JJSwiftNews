//
//  TopicModel.swift
//  JJSwiftNews
//
//  Created by 叶佳骏 on 2017/9/15.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import Foundation

struct NewsTopicSerivce: TopicService {

    static let defaultService = NewsTopicSerivce()
    
    private let topicArray: [[String: String]]
    
    init() {
        if let topicData = UserDefaults.standard.array(forKey: "newsTopics") as? [[String : String]] {
            topicArray = topicData
        } else {
            topicArray = []
        }
    }

    func topicNameArray() -> [String] {
        return topicArray.map({
            return $0["topic"] ?? ""
        })
    }
    
    func topicType(of index: Int) -> String {
        return topicArray[index]["type"] ?? ""
    }
}
