//
//  NewsTopicScrollView.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/24.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
// MVVM
import RxSwift
import RxCocoa

class NewsTopicScrollView: UIView {

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

    internal var currTopicViewIndex = PublishSubject<Int>()
    private var lastTopicViewIndex = 0
    
    // MARK: - Life Cycle
    init(frame: CGRect, topicViewWidth: CGFloat, topicArray: [String]) {
        super.init(frame: frame)
        setupScrollViewContents(topicViewWidth: topicViewWidth, topicArray: topicArray)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设置内容
    private func setupScrollViewContents(topicViewWidth: CGFloat, topicArray: [String]) {
        guard topicArray.count > 0 else { return }
        topicScrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        selectedBottomLine.frame = CGRect(x: 0, y: self.height - 2, width: topicViewWidth, height: 2)
        bottomLine.frame = CGRect(x: 0, y: self.height - 0.5, width: ScreenWidth, height: 0.5)
        topicScrollView.contentSize = CGSize(width: CGFloat(topicArray.count) * topicViewWidth, height: 0)

        for (index, value) in topicArray.enumerated() {
            let topicView = UIButton(frame: CGRect(x: CGFloat(index) * topicViewWidth , y: 0, width: topicViewWidth, height: self.height))
            topicView.backgroundColor = UIColor.white
            topicView.setTitle(value, for: .normal)
            topicView.setTitleColor(index == 0 ? UIColor(valueRGB: 0x4285f4, alpha: 1) : UIColor(valueRGB: 0x999999, alpha: 1), for: .normal)
            topicView.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
            topicView.tag = index.tagByAddingOffset
            topicView.rx.tap.asObservable().subscribe(onNext: { [unowned self] in
                let index = topicView.tag.indexByRemovingOffset
                self.switchToSelectedTopicView(of: index)
                self.currTopicViewIndex.onNext(index)
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
        let lastTopicViewTag = lastTopicViewIndex.tagByAddingOffset
        let lastView = self.topicScrollView.viewWithTag(lastTopicViewTag) as? UIButton
        let currView = self.topicScrollView.viewWithTag(currTopicViewTag) as? UIButton
        guard let currentTopicView = currView, let lastTopicView = lastView else { return }
        lastTopicViewIndex = index
        lastTopicView.setTitleColor(UIColor(valueRGB: 0x999999, alpha: 1), for: .normal)
        currentTopicView.setTitleColor(UIColor(valueRGB: 0x4285f4, alpha: 1), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.selectedBottomLine.frame = CGRect(x: currentTopicView.left, y: currentTopicView.bottom - 2, width: currentTopicView.width, height: 2)
            // topicScrollView根据index自动移动到合适位置
            if index == 0 {
                self.topicScrollView.contentOffset = .zero
            } else {
                let remain  = ScreenWidth.truncatingRemainder(dividingBy: currentTopicView.width)
                let centerX = currentTopicView.left - remain
                let canMove = currentTopicView.left > 0 && currentTopicView.left - remain + ScreenWidth <= self.topicScrollView.contentSize.width
                if canMove {
                    self.topicScrollView.contentOffset = CGPoint(x: centerX, y: 0)
                }
            }

        }
    }
}

// MARK: - UIScrollViewDelegate
extension NewsTopicScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        contentOffset.y = 0
        scrollView.contentOffset = contentOffset
    }
}
