//
//  JJBannerView.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/5/23.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit

@objc(JJBannerViewDelegate)
protocol JJBannerViewDelegate {
    
    func didBannerViewClicked(index: Int)
}

/// Banner基类视图
class JJBannerView: UIView {
    
    // MARK: - Properties
    weak internal var delegate: JJBannerViewDelegate?
    
    fileprivate lazy var bannerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    
    fileprivate lazy var bannerPageController: UIPageControl = {
        let pageController = UIPageControl()
        return pageController
    }()
    
    fileprivate var dataSourceArrayCount = 0             ///<数据源数组长度
    fileprivate var currentBannerIndex = 0               ///<当前Banner位置
    fileprivate var bannerScrollTimer: Timer?            ///<Banner滚动定时器
    
    // MARK: - Life Cycle
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        self.addSubview(bannerScrollView)
        self.addSubview(bannerPageController)
    }

    internal convenience init<T>(frame: CGRect, dataSourceArray: Array<T>) {
        self.init(frame: frame)
        self.setupScrollViewContents(dataSourceArray: dataSourceArray)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设置Banner内容
    internal func setupScrollViewContents(dataSourceArray: Array<Any>) {
        guard dataSourceArray.count > 0 else { return }
        self.dataSourceArrayCount = dataSourceArray.count
        
        bannerScrollView.frame = self.frame
        bannerScrollView.contentSize = CGSize(width: CGFloat(dataSourceArrayCount + 2) * ScreenWidth, height: 0)
        bannerScrollView.removeAllSubviews()
        bannerScrollView.setContentOffset(CGPoint(x: ScreenWidth, y: 0), animated: false)
        
        setupBannerPageControllerFrame(bannerScrollView: bannerScrollView, bannerPageController: bannerPageController, dataSourceArrayCount: dataSourceArrayCount)
        bannerPageController.numberOfPages = dataSourceArrayCount
        
        for index in 0 ..< dataSourceArrayCount + 2 {
            let dataSource: Any
            switch index {
            case 0:
                dataSource = dataSourceArray[dataSourceArrayCount - 1]
            case dataSourceArrayCount + 1:
                dataSource = dataSourceArray[0]
            default:
                dataSource = dataSourceArray[index - 1]
            }
            setupBannerViewContents(bannerScrollView: bannerScrollView, bannerPageController: bannerPageController, index: index, dataSource: dataSource)
        }
    }
    
    // 设置PageController的Frame
    internal func setupBannerPageControllerFrame(bannerScrollView: UIScrollView, bannerPageController: UIPageControl, dataSourceArrayCount: Int) {
    }
    
    // 设置Banner具体内容
    internal func setupBannerViewContents(bannerScrollView: UIScrollView, bannerPageController: UIPageControl, index: Int, dataSource: Any) {
    }
    
}

// MARK: - UIScrollViewDelegate
extension JJBannerView: UIScrollViewDelegate {
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= CGFloat(dataSourceArrayCount + 1) * ScreenWidth {
            // 右滑超过最后页
            bannerScrollView.contentOffset = CGPoint(x: ScreenWidth, y: 0)
        } else if scrollView.contentOffset.x <= 0 {
            // 左划超过第一页
            bannerScrollView.contentOffset = CGPoint(x: CGFloat(dataSourceArrayCount) * ScreenWidth, y: 0)
        }
        currentBannerIndex = Int(bannerScrollView.contentOffset.x / ScreenWidth);
        bannerPageController.currentPage = currentBannerIndex - 1
    }
    
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopScroll()    // 开始拖动时结束自动滚动
    }
    
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startScroll()   // 结束拖动时开始自动滚动
    }
    
    // MARK: 定时器滚动
    internal func startScroll() {
        guard dataSourceArrayCount > 1 else { return }
        stopScroll()   // 先结束上一次的定时器
        bannerScrollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    internal func stopScroll() {
        if let bannerScrollTimer = bannerScrollTimer {
            bannerScrollTimer.invalidate()
            self.bannerScrollTimer = nil
        }
    }
    
    // 滚动到下一页面
    @objc private func scrollToNextPage() {
        currentBannerIndex += 1;
        bannerScrollView.setContentOffset(CGPoint(x: CGFloat(currentBannerIndex) * ScreenWidth, y: 0), animated: true)
//        print(bannerScrollView)
    }
}

// MARK: - Banner图片点击事件处理
extension JJBannerView {
    
    @objc internal func bannerImageViewTapped(sender: UITapGestureRecognizer) {
        let index: Int
        let tappedImageView = sender.view
        if let tappedImageView = tappedImageView {
            switch tappedImageView.tag {
            case 0:
                index = dataSourceArrayCount - 1
            case dataSourceArrayCount + 1:
                index = 0
            default:
                index = tappedImageView.tag - 1
            }
            delegate?.didBannerViewClicked(index: index)
        }
    }
}
