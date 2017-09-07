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
import SnapKit

class JJNewsBannerView: JJBannerView {
    
    // MARK:- 设置PageController的Frame
    override func setupBannerPageControllerFrame(bannerScrollView: UIScrollView, bannerPageController: UIPageControl, bannerViewCount: Int) {
        bannerPageController.snp.remakeConstraints { (make) in
            make.left.equalTo(bannerScrollView.snp.right).offset(-bannerPageControllerWidth)
            make.top.equalTo(bannerScrollView.snp.bottom).offset(-CGFloat(adValue: 22))
            make.width.equalTo(bannerPageControllerWidth)
            make.height.equalTo(CGFloat(adValue: 10))
        }
    }

    override func setupBannerViewContents(bannerView: UIView, bannerModel: BannerModelType) {
        // Banner图片
        let bannerImageView = UIImageView()
        bannerImageView.sd_setImage(with: URL(string: bannerModel.imageLink))
        bannerView.addSubview(bannerImageView)
        // Banner标题
        let bannerTitleLabel = JJTextInsetsLabel(frame: .zero, textInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: bannerPageControllerWidth))
        bannerTitleLabel.backgroundColor = UIColor(valueRGB: 0x000000, alpha: 0.5)
        bannerTitleLabel.text = bannerModel.title
        bannerTitleLabel.textColor = UIColor.white
        bannerTitleLabel.font = UIFont.systemFont(ofSize: CGFloat(adValue: 14))
        bannerView.addSubview(bannerTitleLabel)
        
        bannerImageView.snp.makeConstraints { (make) in
            make.left.equalTo(bannerView)
            make.top.equalTo(bannerView)
            make.size.equalTo(bannerView)
        }
        
        let bannerTitleLabelHeight = CGFloat(adValue: 34)
        bannerTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bannerView)
            make.top.equalTo(bannerView.snp.bottom).offset(-bannerTitleLabelHeight)
            make.width.equalTo(bannerView)
            make.height.equalTo(bannerTitleLabelHeight)
        }
    }
}
