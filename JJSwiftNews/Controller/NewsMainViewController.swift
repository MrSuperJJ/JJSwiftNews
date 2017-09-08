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
var currTopicType = ""                   // 当前选择的TopicType
let newsViewTag = 0.tagByAddingOffset

let topCellReuseIdentifier = "TopCellReuseIdentifier"                        ///<置顶Cell
let norPureTextCellReuseIdentifier = "NorPureTextCellReuseIdentifier"        ///<普通Cell-文本
let norImageTextCellReuseIdentifier = "NorImageTextCellReuseIdentifier"      ///<普通Cell-图文
fileprivate let topCellHeight = CGFloat(adValue: 162)
fileprivate let norCellHeight = CGFloat(adValue: 76)
// MVVM
var currNewsTypeIndex = Variable(0)      ///<当前资讯类型的索引
var currNewsTableView = Variable(UITableView(frame: .zero))
let newsDataSource = RxTableViewSectionedReloadDataSource<SectionOfNews>()

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
                self.view.addSubview(contentScrollView)
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
            newsViewModel.currentTopicTypeChanged.asObservable().subscribe(onNext: { [unowned self] (bannerModelArray, newsModelArray) in
                self.bannerModelArray = bannerModelArray
                contentScrollView.stopPullToRefresh()
            }).disposed(by: disposeBag)
            currNewsTypeIndex.asObservable().map({
                return contentScrollView.viewWithTag($0.tagByAddingOffset) as! UITableView
            }).bind(to: currNewsTableView).disposed(by: disposeBag)
            newsViewModel.currentTopicTypeChanged.asObservable().map({
                return [SectionOfNews(items: [$0.0]), SectionOfNews(items: $0.1)]
            }).bind(to: currNewsTableView.value.rx.items(dataSource: newsDataSource)).disposed(by: disposeBag)
            
            newsDataSource.configureCell = { [unowned self] (section, tableView, indexPath, element) in
                switch indexPath.section {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: topCellReuseIdentifier, for: indexPath)
                    let bannerView = cell.viewWithTag(newsViewTag) as? JJNewsBannerView
                    if let bannerView = bannerView {
                        bannerView.setupScrollViewContents(bannerModelArray: element as! [BannerModelType])
                    } else {
                        let bannerView = JJNewsBannerView(frame: CGRect(x: 0, y:0, width:cell.width, height: topCellHeight))
                        bannerView.shouldScrollAutomatically = true
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
                        let contentView = JJNewsContentView(frame: CGRect(x: 0, y:0, width:cell.width, height: norCellHeight), isPure: isPure)
                        contentView.tag = newsViewTag
                        contentView.updateView(newsModel: element as! NewsModelType)
                        cell.contentView.addSubview(contentView)
                    }
                    return cell
                default:
                    return tableView.dequeueReusableCell(withIdentifier: "norImageTextCellReuseIdentifier")!
                }
            }
            
            currNewsTableView.value.rx.itemSelected.map { indexPath in
                    return (indexPath, newsDataSource[indexPath])
                }.subscribe(onNext: { [unowned self] indexPath, element in
//                    self.openNewsDetailViewController(indexPath: indexPath, element: element)
                }).disposed(by: disposeBag)
            
            currNewsTableView.value.rx.setDelegate(self).disposed(by: disposeBag)
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

extension NewsMainViewController: UITableViewDelegate {

    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(indexPath.section == 0 ? topCellHeight : norCellHeight)
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    fileprivate func openNewsDetailViewController(indexPath: IndexPath, element: Any) {
//        let newsModel = indexPath.section == 0 ? (element as! [BannerModelType])[indexPath.row] : (element as! NewsModelType)
//        let newsDetailController = JJWebViewController()
//        newsDetailController.requestURLPath = newsModel.url
//        self.navigationController?.pushViewController(newsDetailController, animated: true)
//        // 更新已读状态
//        var readedNewsDict = UserDefaults.standard.dictionary(forKey: kReadedNewsKey) ?? [String : Bool]()
//        readedNewsDict["\(newsModel.uniquekey)"] = true
//        UserDefaults.standard.set(readedNewsDict, forKey: kReadedNewsKey)
//        UserDefaults.standard.synchronize()
//        if indexPath.section == 1, let contentScrollView = self.bodyScrollView {
//            contentScrollView.refreshTabaleCellReadedState(index: indexPath.row, isBanner: false)
//        }
//    }
}

// MARK: - 从后台进入前台，更新数据
extension NewsMainViewController {
    
    @objc fileprivate func applicationDidBecomeActive(ntf: Notification) {
//        if let contentScrollView = bodyScrollView {
//            contentScrollView.startPullToRefresh()
//        }
    }
}

