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
    // ViewModel
    fileprivate var newsViewModel: NewsViewModel!                                            ///<ViewModel
    fileprivate var newsDataSources = [RxTableViewSectionedReloadDataSource<SectionOfNews>]()   ///<RxTableViewDataSource
    private var tableViewDataArray = [Variable<[SectionOfNews]>]()                           ///<TableViewData数组

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "资讯"
        // NewsTopicScrollView
        topicScrollView = NewsTopicScrollView(frame: CGRect(x: 0, y: NavBarHeight, width: ScreenWidth, height: 50))
        guard let topicScrollView = topicScrollView else { return }
        self.view.addSubview(topicScrollView)
        // 设置NewsContentScrollView
        bodyScrollView = NewsContentScrollView(frame: CGRect(x: 0, y: topicScrollView.bottom, width: ScreenWidth, height: ScreenHeight - NavBarHeight))
        guard let contentScrollView = bodyScrollView else { return }
        self.view.addSubview(contentScrollView)
        // 切换Topic
        topicScrollView.currTopicViewIndex.asObservable().distinctUntilChanged()
            .subscribe(onNext: {
            contentScrollView.switchToSelectedContentView(of: $0)
        }).disposed(by: disposeBag)
        contentScrollView.currTopicViewIndex.asObservable()
            .subscribe(onNext: {
            topicScrollView.switchToSelectedTopicView(of: $0)
        }).disposed(by: disposeBag)
        // 设置ViewModel
        newsViewModel = NewsViewModel(currContentReLoadIndex: contentScrollView.currContentReLoadIndex.asObservable(),
                                      currContentLoadMoreIndex: contentScrollView.currContentLoadMoreIndex.asObserver())
        newsViewModel.newsTopicNameArray
            .subscribe(onNext: { [unowned self] in
            topicScrollView.setupScrollViewContents(topicViewWidth: CGFloat(77), topicArray: $0)
            contentScrollView.setupScrollView(tableViewCount: $0.count, bind: { index, tableView in
                self.tableViewDataArray.append(Variable([]))
                self.newsDataSources.append(RxTableViewSectionedReloadDataSource<SectionOfNews>())
                self.configureTableViewDataSource(self.newsDataSources[index])
                self.tableViewDataArray[index].asObservable()
                    .bind(to: tableView.rx.items(dataSource: self.newsDataSources[index])).disposed(by: disposeBag)
                self.configureTableViewDelegate(tableView: tableView, index: index)
            })
            contentScrollView.startPullToRefresh(of: 0)
        }).disposed(by: disposeBag)

        newsViewModel.newsContentReloadFinished
            .subscribe(onNext: { [unowned self] result in
                contentScrollView.stopPullToRefresh()
                switch result {
                case .success(let tuple):
                    self.tableViewDataArray[tuple.0].value = tuple.1
                case .failure(let tuple):
                    if self.tableViewDataArray[tuple.0].value.count > 0 {
                        self.showPopView(message: tuple.1.description, showTime: 1)
                    } else {
                        contentScrollView.showNewsErrorRetryView(errorMessage: tuple.1.description)
                    }
                }
                }
            ).disposed(by: disposeBag)
        newsViewModel.newsContentLoadMoreFinished
            .subscribe(onNext: { [unowned self] result in
                contentScrollView.stopLoadingMore()
                switch result {
                case .success(let tuple):
                    tuple.1[1].items.forEach({ model in
                        self.tableViewDataArray[tuple.0].value[1].items += [model]
                    })
                case .failure(let tuple):
                    if self.tableViewDataArray[tuple.0].value.count > 0 {
                        self.showPopView(message: tuple.1.description, showTime: 1)
                    } else {
                        contentScrollView.showNewsErrorRetryView(errorMessage: tuple.1.description)
                    }
                }
                }
            ).disposed(by: disposeBag)
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
        return CGFloat(indexPath.section == 0 ? CGFloat(adValue: 162) : CGFloat(adValue: 76))
    }
    
    fileprivate func configureTableViewDataSource(_ newsDataSource: RxTableViewSectionedReloadDataSource<SectionOfNews>) {
        newsDataSource.configureCell = { (section, tableView, indexPath, element) in
            //            print(tableView.tag)
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: topCellReuseIdentifier, for: indexPath)
                let bannerView = cell.viewWithTag(newsViewTag) as? NewsBannerView
                if let bannerView = bannerView {
                    bannerView.setupScrollViewContents(bannerModelArray: element as! [BannerModelType])
                } else {
                    let bannerView = NewsBannerView(frame: CGRect(x: 0, y:0, width:cell.width, height: cell.height))
                    bannerView.setupScrollViewContents(bannerModelArray: element as! [BannerModelType])
                    bannerView.shouldScrollAutomatically = true
                    bannerView.tag = newsViewTag
                    cell.contentView.addSubview(bannerView)
                    if let tableView = tableView as? NewsTableView {
                        tableView.bannerView = bannerView
                    }
                }
                return cell
            case 1:
                let isPure = (element as! NewsModelType).isPure
                let cellReuseIdentifiter = isPure ? norPureTextCellReuseIdentifier : norImageTextCellReuseIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifiter, for: indexPath)
                let contentView = cell.viewWithTag(newsViewTag) as? NewsContentView
                if let contentView = contentView {
                    contentView.updateView(newsModel: element as! NewsModelType)
                } else {
                    let contentView = NewsContentView(frame: CGRect(x: 0, y:0, width:cell.width, height: cell.height), isPure: isPure)
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
    
    fileprivate func configureTableViewDelegate(tableView: UITableView, index: Int) {
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                return (indexPath, self.newsDataSources[index][indexPath])
            }
            .subscribe(onNext: { [unowned self] indexPath, element in
                tableView.deselectRow(at: indexPath, animated: true)
                let newsModel = indexPath.section == 0 ? (element as! [BannerModelType])[indexPath.row] as! NewsModelType : element as! NewsModelType
                self.openNewsDetailViewController(indexPath: indexPath, newsModel: newsModel)
            })
            .disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    private func openNewsDetailViewController(indexPath: IndexPath, newsModel: NewsModelType) {
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
