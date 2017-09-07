//
//  NewsMainViewController.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/24.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD
// MMVM
import RxSwift
import RxCocoa
var disposeBag = DisposeBag()

let kReadedNewsKey = "ReadedNewsDictKey"
var currTopicType = ""                   // 当前选择的TopicType
// MVVM
var currNewsTypeIndex = Variable(0)      ///<当前资讯类型的索引

class NewsMainViewController: UIViewController {

    // MARK: - Properties
    fileprivate var topicScrollView: JJTopicScrollView?
    fileprivate var bodyScrollView: JJContentScrollView?
    
    fileprivate var newsTopicArray = [["topic": "头条", "type": "top"],
                          ["topic": "社会", "type": "shehui"],
                          ["topic": "国内", "type": "guonei"],
                          ["topic": "国际", "type": "guoji"],
                          ["topic": "娱乐", "type": "yule"],
                          ["topic": "体育", "type": "tiyu"],
                          ["topic": "军事", "type": "junshi"],
                          ["topic": "科技", "type": "keji"],
                          ["topic": "财经", "type": "caijing"],
                          ["topic": "时尚", "type": "shishang"]]
    
    fileprivate var bannerModelArray = [BannerModelType]()
    fileprivate var newsModelArray   = [NewsModelType]()
    fileprivate var lastNewsUniqueKey = ""               // 最后一条资讯的uniquekey
    
    // MARK: MVVM
    fileprivate var newsViewModel: NewsViewModel!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "资讯"

        let topicNameArray = newsTopicArray.flatMap{ $0["topic"] }
        let topicViewWidth = CGFloat(100)
//        let topicViewWidth = ScreenWidth / CGFloat(newsTopicNameArray.count)
        topicScrollView = JJTopicScrollView(frame: CGRect(x: 0, y: NavBarHeight, width: ScreenWidth, height: 50), topicViewWidth: topicViewWidth)
        if let topicScrollView = self.topicScrollView {
            topicScrollView.setupScrollViewContents(dataSourceArray: topicNameArray)
            self.view.addSubview(topicScrollView)
            
            bodyScrollView = JJContentScrollView(frame: CGRect(x: 0, y: topicScrollView.bottom, width: ScreenWidth, height: ScreenHeight - NavBarHeight))
            if let contentScrollView = bodyScrollView {
                contentScrollView.setupScrollView(tableViewCount: topicNameArray.count)
                contentScrollView.delegate = self
                self.view.addSubview(contentScrollView)
                // 在页面初始化后加载数据
                DispatchQueue.main.async {
                    contentScrollView.startPullToRefresh()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(ntf:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // MARK: MVVM
        if let topicScrollView = self.topicScrollView, let contentScrollView = self.bodyScrollView {
            let currentTopicType = currNewsTypeIndex.asObservable().distinctUntilChanged().do(onNext: { (index) in
                topicScrollView.switchToSelectedTopicView(of: index)
                contentScrollView.switchToSelectedContentView(of: index)
            }).map({ [unowned self] index in
                return self.newsTopicArray[index]["type"]!
            })
            newsViewModel = NewsViewModel(input: currentTopicType, dependency: NewsMoyaService.defaultService)
            newsViewModel.currentTopicTypeChanged.asObservable().subscribe(onNext: { (bannerModelArray, newsModelArray) in
                contentScrollView.refreshTableView(bannerModelArray: bannerModelArray, newsModelArray: newsModelArray, isPullToRefresh: true)
                contentScrollView.stopPullToRefresh()
            }).disposed(by: disposeBag)
        }
    }
    
    deinit {
        topicScrollView = nil
        bodyScrollView = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    func showPopView(message: String, showTime: TimeInterval) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + showTime) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

// MARK: - JJContentScrollViewDelegate
extension NewsMainViewController: JJContentScrollViewDelegate {
    
    internal func didTableViewStartRefreshing(index: Int) {
        let bannerModelCount = Int.random(1...4) ///<Banner数量
        currTopicType = self.newsTopicArray[index]["type"]!
        JJNewsAlamofireUtil.requestData(type: currTopicType) { [unowned self] (contentJSON, error) in
            if let contentScrollView = self.bodyScrollView {
                if let contentJSON = contentJSON {
                    self.bannerModelArray.removeAll()
                    self.newsModelArray.removeAll()
                    self.lastNewsUniqueKey = ""
//                    _ = contentJSON.split(whereSeparator: {(index, subJSON) -> Bool in
//                        Int(index)! < bannerModelCount ? self.bannerModelArray.append(BannerModel(subJSON)) : self.newsModelArray.append(NewsModel(subJSON))
//                        if index == String(contentJSON.count - 1) {
//                            self.lastNewsUniqueKey = subJSON["uniquekey"].stringValue
//                        }
//                        return true
//                    })
//                    contentScrollView.refreshTableView(bannerModelArray: self.bannerModelArray, newsModelArray: self.newsModelArray, isPullToRefresh: true)
                } else {
                    if let error = error {
                        print(error.description)
                        switch error {
                        case .networkError:
                            self.showPopView(message: "网络异常", showTime: 1)
                            contentScrollView.showErrorRetryView(errorMessage: error.description)
                        default:
                            contentScrollView.showErrorRetryView(errorMessage: error.description)
                        }
                    }
                }
                contentScrollView.stopPullToRefresh()
            }
        }
    }
    
    internal func didTableViewStartLoadingMore(index: Int) {
        currTopicType = self.newsTopicArray[index]["type"]!
        JJNewsAlamofireUtil.requestData(type: currTopicType) { (contentJSON, error) in
            if let contentScrollView = self.bodyScrollView {
                if let contentJSON = contentJSON {
                    contentScrollView.stopLoadingMore()
//                    _ = contentJSON.split(whereSeparator: {(index, subJSON) -> Bool in
//                        self.newsModelArray.append(NewsModel(subJSON))
//                        if index == String(contentJSON.count - 1) {
//                            self.lastNewsUniqueKey = subJSON["uniquekey"].stringValue
//                        }
//                        return true
//                    })
//                    contentScrollView.refreshTableView(bannerModelArray: self.bannerModelArray, newsModelArray: self.newsModelArray, isPullToRefresh: false)
                } else {
                    if let error = error {
                        print(error.description)
                        switch error {
                        case .networkError:
                            self.showPopView(message: "网络异常", showTime: 1)
                            contentScrollView.stopLoadingMore()
                        case .noMoreDataError:
                            contentScrollView.stopLoadingMoreWithNoMoreData()
                        default:
                            contentScrollView.stopLoadingMore()
                        }
                    }
                }
            }
        }
    }
    
    internal func didTableViewCellSelected(index: Int, isBanner: Bool) {
        let currentModel: Any = isBanner ? bannerModelArray[index] : newsModelArray[index]
        let uniqueKey: String
        let requestURLPath: String
        if let bannerModel = currentModel as? BannerModel {
            uniqueKey = bannerModel.uniquekey
            requestURLPath = bannerModel.url
        } else if let newsModel = currentModel as? NewsModel {
            uniqueKey = newsModel.uniquekey
            requestURLPath = newsModel.url
        } else {
            return
        }
        
        let newsDetailController = JJWebViewController()
        newsDetailController.requestURLPath = requestURLPath
        self.navigationController?.pushViewController(newsDetailController, animated: true)
        // 更新已读状态
        var readedNewsDict = UserDefaults.standard.dictionary(forKey: kReadedNewsKey) ?? [String : Bool]()
        readedNewsDict["\(uniqueKey)"] = true
        UserDefaults.standard.set(readedNewsDict, forKey: kReadedNewsKey)
        UserDefaults.standard.synchronize()
        if !isBanner, let contentScrollView = self.bodyScrollView {
            contentScrollView.refreshTabaleCellReadedState(index: index, isBanner: false)
        }
    }
}

// MARK: - 从后台进入前台，更新数据
extension NewsMainViewController {
    
    @objc fileprivate func applicationDidBecomeActive(ntf: Notification) {
//        if let contentScrollView = bodyScrollView {
//            contentScrollView.startPullToRefresh()
//        }
    }
}

