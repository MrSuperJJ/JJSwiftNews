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
import RxDataSources
var disposeBag = DisposeBag()

let kReadedNewsKey = "ReadedNewsDictKey"
let newsViewTag = 0.tagByAddingOffset                                        ///<NewsViewTag
let topCellReuseIdentifier = "TopCellReuseIdentifier"                        ///<置顶Cell
let norPureTextCellReuseIdentifier = "NorPureTextCellReuseIdentifier"        ///<普通Cell-文本
let norImageTextCellReuseIdentifier = "NorImageTextCellReuseIdentifier"      ///<普通Cell-图文

class NewsMainViewController: UIViewController {

    // MARK: - Properties
    private var topicScrollView: NewsTopicScrollView?
    fileprivate var bodyScrollView: NewsContentScrollView?
    
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
    // TableView
    fileprivate let topCellHeight = CGFloat(adValue: 162)
    fileprivate let norCellHeight = CGFloat(adValue: 76)
    // ViewModel
    fileprivate var newsViewModel: NewsViewModel!                                            ///<ViewModel
    fileprivate let newsDataSource = RxTableViewSectionedReloadDataSource<SectionOfNews>()   ///<RxTableViewDataSource
    private var tableViewDataArray = [Variable<[SectionOfNews]>]()                           ///<TableViewData数组

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "资讯"
        // 设置NewsTopicScrollView
        let topicViewWidth = CGFloat(100)
//        let topicViewWidth = ScreenWidth / CGFloat(newsTopicNameArray.count)
        topicScrollView = NewsTopicScrollView(frame: CGRect(x: 0, y: NavBarHeight, width: ScreenWidth, height: 50), topicViewWidth: topicViewWidth, topicArray: newsTopicArray.flatMap{ $0["topic"] })
        guard let topicScrollView = topicScrollView else { return }
        self.view.addSubview(topicScrollView)
        // 设置NewsContentScrollView
        bodyScrollView = NewsContentScrollView(frame: CGRect(x: 0, y: topicScrollView.bottom, width: ScreenWidth, height: ScreenHeight - NavBarHeight))
        guard let contentScrollView = bodyScrollView else { return }
        configureTableViewDataSource()
        contentScrollView.setupScrollView(tableViewCount: newsTopicArray.count, bind: { index, tableView in
            tableViewDataArray.append(Variable([]))
            tableViewDataArray[index].asObservable().bind(to: tableView.rx.items(dataSource: newsDataSource)).disposed(by: disposeBag)
            tableView.rx.itemSelected
                .map { [unowned self] indexPath in
                    return (indexPath, self.newsDataSource[indexPath])
                }
                .subscribe(onNext: { [unowned self] indexPath, element in
                    tableView.deselectRow(at: indexPath, animated: true)
                    let newsModel = indexPath.section == 0 ? (element as! [BannerModelType])[indexPath.row] as! NewsModelType : element as! NewsModelType
                    self.openNewsDetailViewController(indexPath: indexPath, newsModel: newsModel)
                })
                .disposed(by: disposeBag)
            tableView.rx.setDelegate(self).disposed(by: disposeBag)
        })
        self.view.addSubview(contentScrollView)
        // 切换Topic
        topicScrollView.currTopicViewIndex.asObservable().distinctUntilChanged().subscribe(onNext: {
            contentScrollView.switchToSelectedContentView(of: $0)
        }).disposed(by: disposeBag)
        contentScrollView.currTopicViewIndex.asObservable().subscribe(onNext: {
            topicScrollView.switchToSelectedTopicView(of: $0)
        }).disposed(by: disposeBag)
        // 设置ViewModel
        let currTopicType = contentScrollView.currContentReLoad.asObservable().map({ [unowned self] index in
            return self.newsTopicArray[index]["type"]!
        })
        let lastTopicType = contentScrollView.currContentLoadMore.asObservable().map({ [unowned self] index in
            return self.newsTopicArray[index]["type"]!
        })
        newsViewModel = NewsViewModel(input: (currTopicType: currTopicType, lastTopicType: lastTopicType), dependency: NewsMoyaService.defaultService)
        // 返回数据，更新UI
        Observable.zip(contentScrollView.currContentReLoad.asObservable(), newsViewModel.newsContentReloadFinished.asObservable(), resultSelector: { (index, tuple) in
                return (index, [SectionOfNews(items: [tuple.0]), SectionOfNews(items: tuple.1)])
        })
            .subscribe(onNext: { [unowned self] (index, array) in
                contentScrollView.stopPullToRefresh()
                self.tableViewDataArray[index].value = array
                self.lastNewsUniqueKey = (array.last!.items.last as! NewsModelType).uniquekey
            }).disposed(by: disposeBag)
        Observable.zip(contentScrollView.currContentLoadMore.asObservable(), newsViewModel.newsContentLoadMoreFinished.asObservable(), resultSelector: { (index, tuple) in
            return (index, tuple.1)
        })
            .subscribe(onNext: { [unowned self] (index, newsArray) in
                contentScrollView.stopLoadingMore()
                newsArray.forEach({ model in
                    self.tableViewDataArray[index].value[1].items += [model]
                })
                self.lastNewsUniqueKey = (newsArray.last!).uniquekey
                print(self.tableViewDataArray[index].value[1].items.count)
            }).disposed(by: disposeBag)
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

extension NewsMainViewController: UITableViewDelegate {

    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(indexPath.section == 0 ? topCellHeight : norCellHeight)
    }
    
    fileprivate func openNewsDetailViewController(indexPath: IndexPath, newsModel: NewsModelType) {
        let newsDetailController = JJWebViewController()
        newsDetailController.requestURLPath = newsModel.url
        self.navigationController?.pushViewController(newsDetailController, animated: true)
        // 更新已读状态
        var readedNewsDict = UserDefaults.standard.dictionary(forKey: kReadedNewsKey) ?? [String : Bool]()
        readedNewsDict["\(newsModel.uniquekey)"] = true
        UserDefaults.standard.set(readedNewsDict, forKey: kReadedNewsKey)
        UserDefaults.standard.synchronize()
        if indexPath.section == 1, let contentScrollView = self.bodyScrollView {
            contentScrollView.refreshTabaleCellReadedState(index: indexPath.row, isBanner: false)
        }
    }
}

// MARK: - RxTableViewSectionedReloadDataSource
extension NewsMainViewController {

    func configureTableViewDataSource() {
        newsDataSource.configureCell = { (section, tableView, indexPath, element) in
//            print(tableView.tag)
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: topCellReuseIdentifier, for: indexPath)
                let bannerView = cell.viewWithTag(newsViewTag) as? JJNewsBannerView
                if let bannerView = bannerView {
                    bannerView.setupScrollViewContents(bannerModelArray: element as! [BannerModelType])
                } else {
                    let bannerView = JJNewsBannerView(frame: CGRect(x: 0, y:0, width:cell.width, height: self.topCellHeight))
                    bannerView.setupScrollViewContents(bannerModelArray: element as! [BannerModelType])
                    bannerView.tag = newsViewTag
                    cell.contentView.addSubview(bannerView)
                }
                return cell
            case 1:
                let isPure = (element as! NewsModelType).isPure
                let cellReuseIdentifiter = isPure ? norPureTextCellReuseIdentifier : norImageTextCellReuseIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifiter, for: indexPath)
                let contentView = cell.viewWithTag(newsViewTag) as? JJNewsContentView
                if let contentView = contentView {
                    contentView.updateView(newsModel: element as! NewsModelType)
                } else {
                    let contentView = JJNewsContentView(frame: CGRect(x: 0, y:0, width:cell.width, height: self.norCellHeight), isPure: isPure)
                    contentView.tag = newsViewTag
                    contentView.updateView(newsModel: element as! NewsModelType)
                    cell.contentView.addSubview(contentView)
                }
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "Cell")!
            }
        }
    }
}
