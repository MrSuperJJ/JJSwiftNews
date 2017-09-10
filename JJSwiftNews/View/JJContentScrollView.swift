//
//  JJContentScrollView.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/5/25.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxCocoa

class JJContentScrollView: UIView {
    
    // MARK: - Properties
    fileprivate lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.backgroundColor = UIColor(valueRGB: 0xebebeb, alpha: 1)
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.bounces = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.delegate = self
        return contentScrollView
    }()

    private var errorRetryView: JJErrorRetryView?

    private var currentTableView: UITableView? // 当前显示的TableView
    private var currentBannerView: JJNewsBannerView?
    fileprivate let topCellHeight = CGFloat(adValue: 162)
    fileprivate let norCellHeight = CGFloat(adValue: 76)
    fileprivate var bannerModelArray = [BannerModelType]()
    fileprivate var newsModelArray   = [NewsModelType]()

    private var lastContentViewTag: Int    // 上次选中的ContentView的Tag
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        lastContentViewTag = 0
        super.init(frame: frame)
        self.backgroundColor = UIColor(valueRGB: 0xebebeb, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let currentBannerView = currentBannerView {
            currentBannerView.stopScroll()
        }
    }
    
    // MARK: - Functions
    // TableView切换
    public func switchToSelectedContentView(of index: Int) {
        contentScrollView.setContentOffset(CGPoint(x: CGFloat(index) * self.width, y:0), animated: false)
        startPullToRefresh()
    }

    // 开始下拉刷新（触发时机：1.初次加载，2.页面切换，3.点击错误页面按钮）
    internal func startPullToRefresh() {
        resetLastTableViewState()
        currentTableView = contentScrollView.viewWithTag(currNewsTypeIndex.value.tagByAddingOffset) as? UITableView
        if let currentTableView = self.currentTableView {
            let bannerIndexPath = IndexPath(row: 0, section: 0)
            self.currentBannerView = currentTableView.cellForRow(at: bannerIndexPath)?.viewWithTag(newsViewTag) as? JJNewsBannerView
            currentTableView.mj_header.beginRefreshing()
        }
    }
    
    // 结束下拉刷新
    internal func stopPullToRefresh() {
        if let currentTableView = currentTableView {
            currentTableView.mj_header.endRefreshing()
        }
    }
    
    // 结束加载更多
    internal func stopLoadingMore() {
        if let currentTableView = currentTableView {
            currentTableView.mj_footer.endRefreshing()
        }
    }

    // 结束加载更多（没有更多数据了）
    public func stopLoadingMoreWithNoMoreData() {
        if let currentTableView = currentTableView {
            currentTableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }

    // 重置上一个TableView的状态
    private func resetLastTableViewState() {
        let lastTableView = contentScrollView.viewWithTag(lastContentViewTag) as? UITableView
        if let lastTableView = lastTableView {
            let bannerIndexPath = IndexPath(row: 0, section: 0)
            let lastBannerView = lastTableView.cellForRow(at: bannerIndexPath)?.viewWithTag(newsViewTag) as? JJNewsBannerView
            if let lastBannerView = lastBannerView {
                lastBannerView.stopScroll()         // 停止上一个页面的Banner滚动
            }
            lastTableView.mj_header.endRefreshing() // 停止上一个页面的下拉刷新
        }
    }

    // 刷新TableView内容
//    public func refreshTableView(bannerModelArray: [BannerModelType], newsModelArray: [NewsModelType], isPullToRefresh: Bool) {
//        stopPullToRefresh()
//        self.bannerModelArray = bannerModelArray
//        self.newsModelArray = newsModelArray
//        if let currentTableView = currentTableView {
//            currentTableView.reloadData()
//
//            if isPullToRefresh == true { // 下拉刷新后开启计时器
//                DispatchQueue.main.async { // TableView刷新后启动定时器
//                    if let currentBannerView = self.currentBannerView , currentBannerView.shouldScrollAutomatically == true {
//                        currentBannerView.startScroll()
//                    }
//                }
//            }
//        }
//    }
    
    // 刷新TableViewCell已读状态
    public func refreshTabaleCellReadedState(index: Int, isBanner: Bool) {
        let indexPath = IndexPath(row: index, section: isBanner ? 0 : 1)
        if let currentTableView = currentTableView {
            currentTableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // 设置内容
    public func setupScrollView(tableViewCount: Int, bind: (Int, UITableView) -> Void) {
        guard tableViewCount > 0 else {
            return
        }
        contentScrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        contentScrollView.contentSize = CGSize(width: CGFloat(tableViewCount) * self.width, height: 0)
        
        for index in 0 ..< tableViewCount {
            let contentView = UITableView(frame: CGRect(x: CGFloat(index) * self.width , y: 0, width: self.width, height: self.height))
            contentView.tag = index.tagByAddingOffset
            contentView.separatorStyle = .none
            contentView.register(UITableViewCell.self, forCellReuseIdentifier: topCellReuseIdentifier)
            contentView.register(UITableViewCell.self, forCellReuseIdentifier: norPureTextCellReuseIdentifier)
            contentView.register(UITableViewCell.self, forCellReuseIdentifier: norImageTextCellReuseIdentifier)
            contentScrollView.addSubview(contentView)

            contentView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
                [unowned self] in
                // 停止banner页面滚动
                if let bannerView = self.currentBannerView {
                    bannerView.stopScroll()
                }
                // 隐藏错误信息页面
                if let errorRetryView = self.errorRetryView {
                    errorRetryView.hide()
                }
                contentView.mj_footer.resetNoMoreData()
            })

            let refreshFooter = MJRefreshAutoNormalFooter(refreshingBlock: { [unowned self] in
                // 通知代理对象请求数据
                let index = Int(self.contentScrollView.contentOffset.x / self.width)
            })!
            refreshFooter.setTitle("", for: .idle)
            contentView.mj_footer = refreshFooter
            bind(index, contentView)
        }
        self.addSubview(contentScrollView)

        errorRetryView = JJErrorRetryView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        if let errorRetryView = self.errorRetryView {
            errorRetryView.backgroundColor = UIColor.white
            errorRetryView.hide()
            self.addSubview(errorRetryView)
        }
    }

    // 显示错误信息页面
    internal func showErrorRetryView(errorMessage: String) {
        if let errorRetryView = self.errorRetryView {
            errorRetryView.show(errorMessage: errorMessage, retryClosure: { [unowned self] in
                self.startPullToRefresh()
            })
        }
    }
}

// MARK: - UIScrollViewDelegate
extension JJContentScrollView: UIScrollViewDelegate {
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(contentScrollView.contentOffset.x / self.width)
        currNewsTypeIndex.value = index
        startPullToRefresh()
    }
}

// MARK: - JJBannerViewDelegate
extension JJContentScrollView: JJBannerViewDelegate {
    
    internal func didBannerViewClicked(index: Int) {
//        delegate?.didTableViewCellSelected(index: index, isBanner: true)
    }
}
