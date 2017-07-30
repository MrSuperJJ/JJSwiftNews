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
    override func setupBannerPageControllerFrame(bannerScrollView: UIScrollView, bannerPageController: UIPageControl, bannerViewCount dataSourceArrayCount: Int) {
        bannerPageController.frame = CGRect(x: ScreenWidth - CGFloat(20 * dataSourceArrayCount), y: bannerScrollView.bottom - CGFloat(adValue: 22), width: CGFloat(20 * dataSourceArrayCount), height: CGFloat(adValue: 10))
    }

    override func setupBannerViewContents<T>(bannerView: UIView, bannerPageController: UIPageControl, bannerModel: T) where T : JJBannerModelType {
        guard let bannerModel = bannerModel as? JJBannerModel else { return }
        // Banner图片
        let bannerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: bannerView.width, height: bannerView.height))
        bannerImageView.sd_setImage(with: URL(string: bannerModel.imageLink))
        bannerView.addSubview(bannerImageView)
        // Banner标题
        let bannerTitleLabel = JJTextInsetsLabel(frame: CGRect(x: 0, y: self.height - CGFloat(adValue: 34), width: ScreenWidth, height: CGFloat(adValue: 34)), textInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: bannerPageController.width))
        bannerTitleLabel.backgroundColor = UIColor(valueRGB: 0x000000, alpha: 0.5)
        bannerTitleLabel.text = bannerModel.title
        bannerTitleLabel.textColor = UIColor.white
        bannerTitleLabel.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
        bannerView.addSubview(bannerTitleLabel)
    }
}
