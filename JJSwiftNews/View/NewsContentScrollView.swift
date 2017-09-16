//
//  NewsContentScrollView.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/5/25.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxCocoa

class NewsContentScrollView: UIView {
    
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

    private var errorRetryView: NewsErrorRetryView?
    private var currentTableView: NewsTableView?

    internal var currTopicViewIndex = PublishSubject<Int>()
    internal var currContentReLoadIndex = PublishSubject<Int>()
    internal var currContentLoadMoreIndex = PublishSubject<Int>()
    fileprivate var lastTopicViewIndex = 0
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(valueRGB: 0xebebeb, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let currBannerView = currentTableView?.bannerView {
            currBannerView.stopScroll()
        }
    }
    
    // MARK: - Functions
    // TableView切换
    public func switchToSelectedContentView(of index: Int) {
        lastTopicViewIndex = Int(contentScrollView.contentOffset.x / self.width)
        contentScrollView.setContentOffset(CGPoint(x: CGFloat(index) * self.width, y:0), animated: false)
        resetLastTableViewState()
        startPullToRefresh(of: index)
    }

    // 开始下拉刷新（触发时机：1.初次加载，2.页面切换，3.点击错误页面按钮）
    internal func startPullToRefresh(of index: Int) {
        currentTableView = contentScrollView.viewWithTag(index.tagByAddingOffset) as? NewsTableView
        if let currentTableView = self.currentTableView {
            currentTableView.mj_header.beginRefreshing()
        }
    }
    
    // 结束下拉刷新
    internal func stopPullToRefresh() {
        if let currentTableView = currentTableView {
            currentTableView.mj_header.endRefreshing()
            DispatchQueue.main.async { // TableView刷新后启动定时器
                if let currentBannerView = currentTableView.bannerView , currentBannerView.shouldScrollAutomatically == true {
                    currentBannerView.startScroll()
                }
            }
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
    fileprivate func resetLastTableViewState() {
        let lastTableView = contentScrollView.viewWithTag(lastTopicViewIndex.tagByAddingOffset) as? NewsTableView
        if let lastTableView = lastTableView {
            if let lastBannerView = lastTableView.bannerView {
                lastBannerView.stopScroll()             // 停止上一个页面的Banner滚动
            }
            lastTableView.mj_header.endRefreshing() // 停止上一个页面的下拉刷新
        }
    }
    
    // 刷新TableViewCell已读状态
    public func refreshTabaleCellReadedState(index: Int, isBanner: Bool) {
        let indexPath = IndexPath(row: index, section: isBanner ? 0 : 1)
        if let currentTableView = currentTableView {
            currentTableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // 设置内容
    public func setupScrollView(tableViewCount: Int, bind: (Int, NewsTableView) -> Void) {
        guard tableViewCount > 0 else {
            return
        }
        contentScrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        contentScrollView.contentSize = CGSize(width: CGFloat(tableViewCount) * self.width, height: 0)
        
        for index in 0 ..< tableViewCount {
            let contentView = NewsTableView(frame: CGRect(x: CGFloat(index) * self.width , y: 0, width: self.width, height: self.height))
            contentView.tag = index.tagByAddingOffset
            contentView.separatorStyle = .none
            contentView.register(UITableViewCell.self, forCellReuseIdentifier: topCellReuseIdentifier)
            contentView.register(UITableViewCell.self, forCellReuseIdentifier: norPureTextCellReuseIdentifier)
            contentView.register(UITableViewCell.self, forCellReuseIdentifier: norImageTextCellReuseIdentifier)
            contentScrollView.addSubview(contentView)

            contentView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
                [unowned self] in
                // 停止banner页面滚动
                if let currentBannerView = self.currentTableView?.bannerView{
                    currentBannerView.stopScroll()
                }
                // 隐藏错误信息页面
                if let errorRetryView = self.errorRetryView {
                    errorRetryView.hide()
                }
                contentView.mj_footer.resetNoMoreData()
                
                let index = Int(self.contentScrollView.contentOffset.x / self.width)
                self.currContentReLoadIndex.onNext(index)
            })

            let refreshFooter = MJRefreshAutoNormalFooter(refreshingBlock: { [unowned self] in
                let index = Int(self.contentScrollView.contentOffset.x / self.width)
                self.currContentLoadMoreIndex.onNext(index)
            })!
            refreshFooter.setTitle("", for: .idle)
            contentView.mj_footer = refreshFooter
            bind(index, contentView)
        }
        self.addSubview(contentScrollView)

        errorRetryView = NewsErrorRetryView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        if let errorRetryView = self.errorRetryView {
            errorRetryView.backgroundColor = UIColor.white
            errorRetryView.hide()
            self.addSubview(errorRetryView)
        }
    }
    

    // 显示错误信息页面
    internal func showNewsErrorRetryView(errorMessage: String) {
        if let errorRetryView = self.errorRetryView {
            errorRetryView.show(errorMessage: errorMessage, retryClosure: { [unowned self] in
                let index = Int(self.contentScrollView.contentOffset.x / self.width)
                self.startPullToRefresh(of: index)
            })
        }
    }
}

// MARK: - UIScrollViewDelegate
extension NewsContentScrollView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastTopicViewIndex = Int(scrollView.contentOffset.x / self.width)
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(contentScrollView.contentOffset.x / self.width)
        if index == lastTopicViewIndex { return }
        currTopicViewIndex.onNext(index)
        resetLastTableViewState()
        startPullToRefresh(of: index)
    }
}
