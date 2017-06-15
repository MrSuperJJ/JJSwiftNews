//
//  JJtopicScrollView.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/24.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit

@objc(JJTopicScrollViewDelegate)
protocol JJTopicScrollViewDelegate {
    
    func didtopicViewChanged(index: Int, value: String)
}

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
    private let topicViewTagIndex = 1000                               // topicViewTag偏移量
    private var lastTopicViewTag: Int                                  // 最近一次选中topicView的Tag
    private var dataSourceArray: Array<String>?
    weak public var delegate: JJTopicScrollViewDelegate?

    // MARK: - Life Cycle
    init(frame: CGRect, topicViewWidth: CGFloat) {
        self.topicViewWidth = topicViewWidth
        self.lastTopicViewTag = topicViewTagIndex
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
            topicView.tag = index + topicViewTagIndex
            topicView.addTarget(self, action: #selector(topicViewClicked(sender:)), for: .touchUpInside)
            topicScrollView.addSubview(topicView)
        }

        self.addSubview(topicScrollView)
        topicScrollView.addSubview(selectedBottomLine)
        self.addSubview(bottomLine)
    }

    // MARK: topic点击
    @objc private func topicViewClicked(sender: UIButton) {
        let currTopicViewTag = sender.tag
        let lastView = topicScrollView.viewWithTag(lastTopicViewTag) as? UIButton
        let currView = topicScrollView.viewWithTag(currTopicViewTag) as? UIButton
        guard let currentTopicView = currView, let lastTopicView = lastView else {
            return
        }
        lastTopicViewTag = currTopicViewTag
        lastTopicView.setTitleColor(UIColor(valueRGB: 0x999999, alpha: 1), for: .normal)
        currentTopicView.setTitleColor(UIColor(valueRGB: 0x4285f4, alpha: 1), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.selectedBottomLine.frame = CGRect(x: currentTopicView.left, y: currentTopicView.bottom - 2, width: currentTopicView.width, height: 2)
        }
        if let dataSourceArray = dataSourceArray {
            let index = currTopicViewTag-topicViewTagIndex
            delegate?.didtopicViewChanged(index: index, value: dataSourceArray[index])
        }
    }

    // MARK: topicView切换
    public func switchToSelectedtopicView(index: Int) {
        let currentTopicViewTag = index + topicViewTagIndex
        let lastView = topicScrollView.viewWithTag(lastTopicViewTag) as? UIButton
        let currentView = topicScrollView.viewWithTag(currentTopicViewTag) as? UIButton
        guard let currentTopicView = currentView, let lastTopicView = lastView else {
            return
        }
        lastTopicViewTag = currentTopicViewTag
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
