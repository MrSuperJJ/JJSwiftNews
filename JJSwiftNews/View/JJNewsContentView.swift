//
//  JJNewsContentView.swift
//  JJSwiftDemo
//
//  Created by yejiajun on 2017/5/27.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class JJNewsContentView: UIView {
    
    // MARK: - Properties
    /// 资讯图片视图
    private lazy var newsImageView: UIImageView = {
        let newsImageView = UIImageView()
        newsImageView.backgroundColor = UIColor.gray
        return newsImageView
    }()
    /// 资讯文本内容视图
    private lazy var newsContentView: UIView = {
        let newsContentView = UIView()
        newsContentView.backgroundColor = UIColor.clear
        return newsContentView
    }()
    /// 资讯标题视图
    private lazy var newsTitleLabel: UILabel = {
        let newsTitleLabel = UILabel()
        newsTitleLabel.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
        newsTitleLabel.numberOfLines = 0
        newsTitleLabel.lineBreakMode = .byTruncatingTail
        return newsTitleLabel
    }()
    /// 资讯副标题视图
    private lazy var newsSubTitleLabel: UILabel = {
        let newsSubTitleLabel = UILabel()
        newsSubTitleLabel.textColor = UIColor(valueRGB: 0x999999, alpha: 1)
        newsSubTitleLabel.font = UIFont.systemFont(ofSize: CGFloat(adValue: 12))
        newsSubTitleLabel.lineBreakMode = .byCharWrapping
        return newsSubTitleLabel
    }()
    /// 分割线
    private lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(valueRGB: 0xdcdcdc, alpha: 1)
        return bottomLine
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
        
        self.addSubview(newsContentView)
        newsContentView.addSubview(newsTitleLabel)
        newsContentView.addSubview(newsSubTitleLabel)
        self.addSubview(bottomLine)
        // 资讯图片和内容
        if isPure { // 纯文本界面
            newsContentView.snp.makeConstraints { (make) in
                make.left.equalTo(self).offset(CGFloat(adValue:10))
                make.top.equalTo(self).offset(CGFloat(adValue: subViewTop))
                make.right.equalTo(self).offset(CGFloat(adValue:-10))
                make.height.equalTo(CGFloat(adValue:subViewHeight))
            }
        } else {    // 图文界面
            self.addSubview(newsImageView)
            newsImageView.snp.makeConstraints({ (make) in
                make.left.equalTo(self).offset(CGFloat(adValue: 10))
                make.top.equalTo(self).offset(CGFloat(adValue: subViewTop))
                make.width.equalTo(CGFloat(adValue: 76.5))
                make.height.equalTo(CGFloat(adValue: subViewHeight))
            })

            newsContentView.snp.makeConstraints { (make) in
                make.left.equalTo(newsImageView.snp.right).offset(CGFloat(adValue:8))
                make.top.equalTo(newsImageView)
                make.right.equalTo(self).offset(CGFloat(adValue:-10))
                make.height.equalTo(CGFloat(adValue:subViewHeight))
            }
        }
        // 资讯标题
        newsTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(newsContentView)
            make.top.equalTo(newsContentView)
            make.bottom.equalTo(newsSubTitleLabel.snp.top).offset(CGFloat(adValue: -6))
            make.width.equalTo(newsContentView)
        }
        // 资讯副标题
        newsSubTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(newsContentView)
            make.bottom.equalTo(newsContentView)
            make.width.equalTo(newsContentView)
            make.height.equalTo(CGFloat(adValue: 12))
        }
        // 分割线
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-0.5)
            make.width.equalTo(self)
            make.height.equalTo(0.5)
        }
    }

    // MARK: - 更新页面数据
    internal func updateView(newsModel: JJNewsModelType) {
        guard let newsModel = newsModel as? JJNewsModel else { return }
        // 资讯图片
        if !newsModel.isPure {
            newsImageView.sd_setImage(with: URL(string: newsModel.imageLink))
        }
        // 资讯标题
        newsTitleLabel.text =  newsModel.title
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
        newsTitleLabel.textColor = titleTextColor
        // 资讯副标题
        newsSubTitleLabel.text = newsModel.authorName
    }
}


