//
//  JJtopicScrollView.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/24.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
// MVVM
import RxSwift

class JJTopicScrollView: UIView {

    // MARK: - Properties
    private lazy var topicScrollView: UIScrollView = {
        let topicScrollView = UIScrollView()
        topicScrollView.backgroundColor = UIColor.white
        topicScrollView.showsHorizontalScrollIndicator = false
        topicScrollView.showsVerticalScrollIndicator = false
        topicScrollView.bounces = false
        topicScrollView.delegate = self
        return topicScrollView
    }()

    private lazy var selectedBottomLine: UIView = {
        let selectedBottomLine = UIView()
        selectedBottomLine.backgroundColor = UIColor(valueRGB: 0x4285f4, alpha: 1)
        return selectedBottomLine
    }()

    private lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(valueRGB: 0x999999, alpha: 0.5)
        return bottomLine
    }()

    private var topicViewWidth: CGFloat                                // 每个topicView宽度
    private var lastTopicViewTag: Int                                  // 最近一次选中topicView的Tag
    private var dataSourceArray: Array<String>?
    
    // MARK: - Life Cycle
    init(frame: CGRect, topicViewWidth: CGFloat) {
        self.topicViewWidth = topicViewWidth
        self.lastTopicViewTag = 0.tagByAddingOffset
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设置内容
    public func setupScrollViewContents(dataSourceArray: Array<String>) {
        guard dataSourceArray.count > 0 else {
            return
        }
        self.dataSourceArray = dataSourceArray
        topicScrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        selectedBottomLine.frame = CGRect(x: 0, y: self.height - 2, width: topicViewWidth, height: 2)
        bottomLine.frame = CGRect(x: 0, y: self.height - 0.5, width: ScreenWidth, height: 0.5)
        topicScrollView.contentSize = CGSize(width: CGFloat(dataSourceArray.count) * topicViewWidth, height: 0)

        for (index, value) in dataSourceArray.enumerated() {
            let topicView = UIButton(frame: CGRect(x: CGFloat(index) * topicViewWidth , y: 0, width: topicViewWidth, height: self.height))
            topicView.backgroundColor = UIColor.white
            topicView.setTitle(value, for: .normal)
            topicView.setTitleColor(index == 0 ? UIColor(valueRGB: 0x4285f4, alpha: 1) : UIColor(valueRGB: 0x999999, alpha: 1), for: .normal)
            topicView.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
            topicView.tag = index.tagByAddingOffset
            topicView.rx.tap.asObservable().subscribe(onNext: {
                currNewsTypeIndex.value = topicView.tag.indexByRemovingOffset
            }).disposed(by: disposeBag)
            topicScrollView.addSubview(topicView)
        }

        self.addSubview(topicScrollView)
        topicScrollView.addSubview(selectedBottomLine)
        self.addSubview(bottomLine)
    }
    
    /// 切换资讯TopicView
    ///
    /// - Parameter index: Topic索引
    internal func switchToSelectedTopicView(of index: Int) {
        let currTopicViewTag = index.tagByAddingOffset
        guard currTopicViewTag != self.lastTopicViewTag else { return }
        let lastView = self.topicScrollView.viewWithTag(self.lastTopicViewTag) as? UIButton
        let currView = self.topicScrollView.viewWithTag(currTopicViewTag) as? UIButton
        guard let currentTopicView = currView, let lastTopicView = lastView else { return }
        self.lastTopicViewTag = currTopicViewTag
        lastTopicView.setTitleColor(UIColor(valueRGB: 0x999999, alpha: 1), for: .normal)
        currentTopicView.setTitleColor(UIColor(valueRGB: 0x4285f4, alpha: 1), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.selectedBottomLine.frame = CGRect(x: currentTopicView.left, y: currentTopicView.bottom - 2, width: currentTopicView.width, height: 2)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension JJTopicScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        contentOffset.y = 0
        scrollView.contentOffset = contentOffset
    }
}
