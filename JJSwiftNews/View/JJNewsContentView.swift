//
//  JJNewsContentView.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/5/27.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import SwiftyJSON

class JJNewsContentView: UIView {
    
    // MARK: - Properties
    ///<资讯图片视图
    private lazy var newsImageView: UIImageView = {
        let newsImageView = UIImageView()
        newsImageView.backgroundColor = UIColor.gray
        return newsImageView
    }()
    ///<资讯文本内容视图
    private lazy var newsContentView: UIView = {
        let newsContentView = UIView()
        newsContentView.backgroundColor = UIColor.clear
        return newsContentView
    }()
    ///<资讯标题视图
    private lazy var newsTitleView: UILabel = {
        let newsTitleView = UILabel()
        newsTitleView.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
        newsTitleView.numberOfLines = 0
        newsTitleView.lineBreakMode = .byCharWrapping
        return newsTitleView
    }()
    ///<资讯副标题视图
    private lazy var newsSubTitleView: UILabel = {
        let newsSubTitleView = UILabel()
        newsSubTitleView.textColor = UIColor(valueRGB: 0x999999, alpha: 1)
        newsSubTitleView.font = UIFont.systemFont(ofSize: CGFloat(adValue: 12))
        newsSubTitleView.numberOfLines = 0
        newsSubTitleView.lineBreakMode = .byCharWrapping
        return newsSubTitleView
    }()
    
    // MARK: - Life Cycle
    internal init(frame: CGRect, isPure: Bool) {
        super.init(frame: frame)
        self.setupViewFrame(isPure: isPure)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    // MARK: - 设置页面布局
    internal func setupViewFrame(isPure: Bool) {
        let subViewTop: CGFloat = 8
        let subViewHeight: CGFloat = 60
        // 资讯图片和内容
        if isPure { // 纯文本界面
            newsContentView.frame = CGRect(x: CGFloat(adValue:10), y: CGFloat(adValue:subViewTop), width: ScreenWidth - CGFloat(adValue:10) - CGFloat(adValue:10), height: CGFloat(adValue:subViewHeight))
        } else {    // 图文界面
            newsImageView.frame = CGRect(adX: 10, adY: subViewTop, adWidth: 76.5, adHeight: subViewHeight)
            self.addSubview(newsImageView)

            newsContentView.frame = CGRect(x: newsImageView.right + CGFloat(adValue:8), y: newsImageView.top, width: ScreenWidth - newsImageView.right - CGFloat(adValue:8) - CGFloat(adValue:10), height: CGFloat(adValue:subViewHeight))
        }
        self.addSubview(newsContentView)
        // 资讯标题
        newsTitleView.frame = CGRect(x: 0, y: 0, width: newsContentView.width, height: CGFloat(adValue:14))
        newsContentView.addSubview(newsTitleView)
        // 资讯副标题
        newsSubTitleView.frame = CGRect(x: 0, y: newsTitleView.bottom + CGFloat(adValue:6), width: newsContentView.width, height: CGFloat(adValue:12))
        newsContentView.addSubview(newsSubTitleView)
        // 分割线
        let bottomLine = UIView(frame: CGRect(x: 0, y: self.height - 0.5, width: ScreenWidth, height: 0.5))
        bottomLine.backgroundColor = UIColor(valueRGB: 0xdcdcdc, alpha: 1)
        self.addSubview(bottomLine)
    }

    // MARK: - 更新页面数据
    internal func updateView(newsModel: JJNewsModelType) {
        guard let newsModel = newsModel as? JJNewsModel else { return }
        // 资讯图片
        if !newsModel.isPure {
            newsImageView.sd_setImage(with: URL(string: newsModel.imageLink))
        }
        // 资讯标题
        var newsTitleViewText = newsModel.title
        let maxTextLength = (newsModel.isPure == true ? 40 : 30) - 3
        if newsTitleViewText.characters.count > maxTextLength {
            let index = newsTitleViewText.index(newsTitleViewText.startIndex, offsetBy: maxTextLength)
            newsTitleViewText = newsTitleViewText.substring(to: index)
            newsTitleViewText += "..."
        }
        newsTitleView.frame = CGRect(x: newsTitleView.left, y: newsTitleView.top, width: newsContentView.width, height: fetchHeightForMultipleLinesText(newsTitleViewText, width: newsContentView.width, font: UIFont.systemFont(ofSize: CGFloat(adValue: 14)), lineSpacing: 4))
        newsTitleView.text = newsTitleViewText
        // 资讯标题已读状态颜色
        var titleTextColor = UIColor(valueRGB: 0x333333, alpha: 1)
        let readedNewsDict = UserDefaults.standard.dictionary(forKey: kReadedNewsKey) as? [String : Bool]
        if let readedNewsDict = readedNewsDict {
            let uniqueKey = newsModel.uniquekey
            let isNewsReaded = readedNewsDict["\(uniqueKey)"]
            if let isNewsReaded = isNewsReaded, isNewsReaded == true {
                titleTextColor = UIColor(valueRGB: 0x999999, alpha: 1)
            }
        }
        newsTitleView.textColor = titleTextColor
        // 资讯副标题
        newsSubTitleView.frame = CGRect(x: 0, y: newsTitleView.bottom + CGFloat(adValue:6), width: newsContentView.width, height: CGFloat(adValue:12))
        let subTitleViewText = newsModel.authorName
        newsSubTitleView.text = subTitleViewText
    }
}


