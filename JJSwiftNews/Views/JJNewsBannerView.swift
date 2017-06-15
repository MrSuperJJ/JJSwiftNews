//
//  JJNewsBannerView.swift
//  e企_2015
//
//  Created by yejiajun on 2017/6/9.
//  Copyright © 2017年 中移（杭州）信息技术有限公司. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class JJNewsBannerView: JJBannerView {
    
    // MARK:- 设置PageController的Frame
    override func setupBannerPageControllerFrame(bannerScrollView: UIScrollView, bannerPageController: UIPageControl, dataSourceArrayCount: Int) {
        bannerPageController.frame = CGRect(x: ScreenWidth - CGFloat(20 * dataSourceArrayCount), y: bannerScrollView.bottom - CGFloat(adValue: 22), width: CGFloat(20 * dataSourceArrayCount), height: CGFloat(adValue: 10))
    }
    
    // MARK: - 设置Banner具体内容
    override func setupBannerViewContents(bannerScrollView:UIScrollView, bannerPageController: UIPageControl, index: Int, dataSource: Any) {
        let jsonData = dataSource as! JSON
        let imageURL = jsonData["thumbnail_pic_s"].stringValue
        let title = jsonData["title"].stringValue

        // Banner图片
        let bannerImageView = UIImageView(frame: self.frame)
        bannerImageView.center = CGPoint(x: (CGFloat(index)+0.5) * self.width, y: self.height * 0.5)
        bannerImageView.backgroundColor = UIColor.gray
        bannerImageView.sd_setImage(with: URL(string: imageURL))
        bannerImageView.tag = index
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bannerImageViewTapped(sender:)))
        bannerImageView.addGestureRecognizer(tapGestureRecognizer)
        bannerImageView.isUserInteractionEnabled = true
        bannerScrollView.addSubview(bannerImageView)
        // Banner标题
        let bannerTitleLabel = JJTextInsetsLabel(frame: CGRect(x: 0, y: self.height - CGFloat(adValue: 34), width: ScreenWidth, height: CGFloat(adValue: 34)), textInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: bannerPageController.width))
        bannerTitleLabel.center = CGPoint(x: (CGFloat(index)+0.5) * self.width, y: bannerTitleLabel.center.y)
        bannerTitleLabel.backgroundColor = UIColor(valueRGB: 0x000000, alpha: 0.5)
        bannerTitleLabel.text = title
        bannerTitleLabel.textColor = UIColor.white
        bannerTitleLabel.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
        bannerScrollView.addSubview(bannerTitleLabel)
    }
}
