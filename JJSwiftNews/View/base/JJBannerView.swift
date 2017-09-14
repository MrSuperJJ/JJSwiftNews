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
    // 是否手动拖动后继续自动滚动，默认为false
    internal var shouldScrollAutomatically = false

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
        pageController.hidesForSinglePage = true
        return pageController
    }()
    
    fileprivate var bannerViewCount = 0                  ///<Banner视图数量
    fileprivate var currentBannerIndex = 0               ///<当前Banner位置
    fileprivate var bannerScrollTimer: Timer?            ///<Banner滚动定时器
    internal var bannerPageControllerWidth: CGFloat = 0  ///<PageController宽度

    
    // MARK: - Life Cycle
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        self.addSubview(bannerScrollView)
        self.addSubview(bannerPageController)
        bannerScrollView.frame = self.frame
    }

    internal convenience init(frame: CGRect, bannerModelArray: [BannerModelType]) {
        self.init(frame: frame)
        self.setupScrollViewContents(bannerModelArray: bannerModelArray)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 设置Banner内容
    final internal func setupScrollViewContents(bannerModelArray: [BannerModelType]) {
        guard bannerModelArray.count > 0 else { return }
        self.bannerViewCount = bannerModelArray.count
        bannerPageControllerWidth = CGFloat(20 * bannerViewCount)
        bannerPageController.numberOfPages = bannerViewCount
        bannerScrollView.removeAllSubviews()

        if bannerViewCount == 1 {
            bannerScrollView.contentSize = CGSize(width: self.width, height: 0)
            let index = 0
            let bannerView = fetchBannerView(index: index)
            bannerScrollView.addSubview(bannerView)
            setupBannerViewContents(bannerView: bannerView, bannerModel: bannerModelArray[0])
        } else {
            bannerScrollView.contentSize = CGSize(width: CGFloat(bannerViewCount + 2) * self.width, height: 0)
            bannerScrollView.contentOffset = CGPoint(x: self.width, y: 0)
            setupBannerPageControllerFrame(bannerScrollView: bannerScrollView, bannerPageController: bannerPageController, bannerViewCount: bannerViewCount)

            for index in 0 ..< bannerViewCount + 2 {
                let bannerView = fetchBannerView(index: index)
                bannerScrollView.addSubview(bannerView)
                let realIndex: Int
                switch index {
                case 0:
                    realIndex = bannerViewCount - 1
                case bannerViewCount + 1:
                    realIndex = 0
                default:
                    realIndex = index - 1
                }
                setupBannerViewContents(bannerView: bannerView, bannerModel: bannerModelArray[realIndex])
            }
        }
    }

    /// 返回每个Banner视图的父类
    ///
    /// - Parameter index: 下标
    /// - Returns: BannerView
    private func fetchBannerView(index: Int) -> UIView {
        let bannerView = UIView(frame: self.frame)
        bannerView.center = CGPoint(x: (CGFloat(index)+0.5) * bannerScrollView.width, y: bannerScrollView.height * 0.5)
        bannerView.tag = index
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bannerImageViewTapped(sender:)))
        bannerView.addGestureRecognizer(tapGestureRecognizer)
        return bannerView
    }

    /// 设置PageController的布局
    ///
    /// - Parameters:
    ///   - bannerScrollView: 已初始化的bannerScrollView
    ///   - bannerPageController: 已初始化的bannerPageController
    ///   - bannerViewCount: bannerView数量
    internal func setupBannerPageControllerFrame(bannerScrollView: UIScrollView, bannerPageController: UIPageControl, bannerViewCount: Int) {
    }

    /// 设置Banner内容
    ///
    /// - Parameters:
    ///   - bannerView: Banner内容的父视图
    ///   - bannerModel: 遵循JJBannerModelType的Model
    internal func setupBannerViewContents(bannerView: UIView, bannerModel: BannerModelType) {
    }
    
}

// MARK: - UIScrollViewDelegate
extension JJBannerView: UIScrollViewDelegate {
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if bannerViewCount == 1 { return }
        if scrollView.contentOffset.x >= CGFloat(bannerViewCount + 1) * self.width {
            // 右滑超过最后页
            bannerScrollView.contentOffset = CGPoint(x: self.width, y: 0)
        } else if scrollView.contentOffset.x <= 0 {
            // 左划超过第一页
            bannerScrollView.contentOffset = CGPoint(x: CGFloat(bannerViewCount) * self.width, y: 0)
        }
        currentBannerIndex = Int(bannerScrollView.contentOffset.x / self.width);
        bannerPageController.currentPage = currentBannerIndex - 1
    }
    
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopScroll()    // 开始拖动时结束自动滚动
    }
    
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if shouldScrollAutomatically == true {
            startScroll()   // 结束拖动时开始自动滚动
        }
    }
    
    // MARK: 定时器滚动
    internal func startScroll() {
        guard bannerViewCount > 1 else { return }
//        stopScroll()   // 先结束上一次的定时器
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
        bannerScrollView.setContentOffset(CGPoint(x: CGFloat(currentBannerIndex) * self.width, y: 0), animated: true)
//        print(bannerScrollView.contentOffset)
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
                index = bannerViewCount - 1
            case bannerViewCount + 1:
                index = 0
            default:
                index = tappedImageView.tag - 1
            }
            delegate?.didBannerViewClicked(index: index)
        }
    }
}
