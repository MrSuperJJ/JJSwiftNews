//
//  JJContentScrollView.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/5/25.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
// MVVM
import RxSwift
import RxCocoa

@objc(JJContentScrollViewDelegate)
protocol JJContentScrollViewDelegate {

    func didTableViewStartLoadingMore(index: Int)
    
    func didTableViewCellSelected(index: Int, isBanner: Bool)
}

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

    private var currentTableView: JJContentTableView? // 当前显示的TableView
    private var currentBannerView: JJNewsBannerView?
    fileprivate let topCellReuseIdentifier = "TopCellReuseIdentifier"                        ///<置顶Cell
    fileprivate let norPureTextCellReuseIdentifier = "NorPureTextCellReuseIdentifier"        ///<普通Cell-文本
    fileprivate let norImageTextCellReuseIdentifier = "NorImageTextCellReuseIdentifier"      ///<普通Cell-图文
    fileprivate let topCellHeight = CGFloat(adValue: 162)
    fileprivate let norCellHeight = CGFloat(adValue: 76)
    fileprivate var bannerModelArray = [BannerModelType]()
    fileprivate var newsModelArray   = [NewsModelType]()

    fileprivate let contentViewTagIndex = 1000 // 初始ContentView的Tag偏移量
    private var lastContentViewTag: Int    // 上次选中的ContentView的Tag
    private var currContentViewTag: Int    // 当前选中的ContentView的Tag

    weak internal var delegate: JJContentScrollViewDelegate?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        lastContentViewTag = 0
        currContentViewTag = contentViewTagIndex
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
    public func startPullToRefresh() {
        resetLastTableViewState()
        currentTableView = contentScrollView.viewWithTag(currContentViewTag) as? JJContentTableView
        if let currentTableView = self.currentTableView {
            let bannerIndexPath = IndexPath(row: 0, section: 0)
            self.currentBannerView = currentTableView.cellForRow(at: bannerIndexPath)?.viewWithTag(self.contentViewTagIndex) as? JJNewsBannerView
            currentTableView.mj_header.beginRefreshing()
        }
    }
    
    // 结束下拉刷新
    public func stopPullToRefresh() {
        if let currentTableView = currentTableView {
            currentTableView.mj_header.endRefreshing()
        }
    }
    
    // 结束加载更多
    public func stopLoadingMore() {
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
        let lastTableView = contentScrollView.viewWithTag(lastContentViewTag) as? JJContentTableView
        if let lastTableView = lastTableView {
            let bannerIndexPath = IndexPath(row: 0, section: 0)
            let lastBannerView = lastTableView.cellForRow(at: bannerIndexPath)?.viewWithTag(contentViewTagIndex) as? JJNewsBannerView
            if let lastBannerView = lastBannerView {
                lastBannerView.stopScroll()         // 停止上一个页面的Banner滚动
            }
            lastTableView.mj_header.endRefreshing() // 停止上一个页面的下拉刷新
        }
    }

    // 刷新TableView内容
    public func refreshTableView(bannerModelArray: [BannerModelType], newsModelArray: [NewsModelType], isPullToRefresh: Bool) {
        self.bannerModelArray = bannerModelArray
        self.newsModelArray = newsModelArray
        if let currentTableView = currentTableView {
            currentTableView.hasReloadDataBefore = true
            currentTableView.reloadData()

            if isPullToRefresh == true { // 下拉刷新后开启计时器
                DispatchQueue.main.async { // TableView刷新后启动定时器
                    if let currentBannerView = self.currentBannerView , currentBannerView.shouldScrollAutomatically == true {
                        currentBannerView.startScroll()
                    }
                }
            }
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
    public func setupScrollView(tableViewCount: Int) {
        guard tableViewCount > 0 else {
            return
        }
        contentScrollView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        contentScrollView.contentSize = CGSize(width: CGFloat(tableViewCount) * self.width, height: 0)
        
        for index in 0 ..< tableViewCount {
            let contentView = JJContentTableView(frame: CGRect(x: CGFloat(index) * self.width , y: 0, width: self.width, height: self.height))
            contentView.tag = index + contentViewTagIndex
            contentView.delegate = self
            contentView.dataSource = self
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
                self.delegate?.didTableViewStartLoadingMore(index: index)
            })!
            refreshFooter.setTitle("", for: .idle)
            contentView.mj_footer = refreshFooter
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
        if currentTableView?.hasReloadDataBefore == true {
            return
        }
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

// MARK: - UITableViewDelegate / UITableViewDataSource
extension JJContentScrollView: UITableViewDelegate, UITableViewDataSource {
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return newsModelArray.count
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat
        if indexPath.section == 0 {
            height = topCellHeight
        } else {
            height = norCellHeight
        }
        return CGFloat(height)
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: topCellReuseIdentifier, for: indexPath)
            let bannerView = cell.viewWithTag(contentViewTagIndex) as? JJNewsBannerView
            if let bannerView = bannerView {
                bannerView.setupScrollViewContents(bannerModelArray: bannerModelArray)
            } else {
                let bannerView = JJNewsBannerView(frame: CGRect(x: 0, y:0, width:self.width, height: topCellHeight))
                bannerView.delegate = self
                bannerView.shouldScrollAutomatically = true
                bannerView.tag = contentViewTagIndex
                cell.contentView.addSubview(bannerView)
            }
            return cell
        } else {
            let newsModel = newsModelArray[indexPath.row]
            let isPure = newsModel.isPure
            let cellReuseIdentifiter = isPure ? norPureTextCellReuseIdentifier : norImageTextCellReuseIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifiter, for: indexPath)
            if newsModelArray.count > indexPath.row {
                let contentView = cell.viewWithTag(contentViewTagIndex) as? JJNewsContentView
                if let contentView = contentView {
                    contentView.updateView(newsModel: newsModel)
                } else {
                    let contentView = JJNewsContentView(frame: CGRect(x: 0, y:0, width:self.width, height: norCellHeight), isPure: isPure)
                    contentView.tag = contentViewTagIndex
                    contentView.updateView(newsModel: newsModel)
                    cell.contentView.addSubview(contentView)
                }
            }
            return cell
        }
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didTableViewCellSelected(index: indexPath.row, isBanner: false)
    }
}

// MARK: - JJBannerViewDelegate
extension JJContentScrollView: JJBannerViewDelegate {
    
    internal func didBannerViewClicked(index: Int) {
        delegate?.didTableViewCellSelected(index: index, isBanner: true)
    }
}
