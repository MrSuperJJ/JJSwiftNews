//
//  JJErrorRetryView.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/29.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit

class JJErrorRetryView: UIView {

    private let noNetImageView: UIImageView
    private let errorLabel: UILabel
    private let retryButton: UIButton

    internal var errorTextColor: UIColor?
    internal var errorFont: UIFont?

    private var retryClosure: (() -> Void)?

    internal override init(frame: CGRect) {
        self.noNetImageView = UIImageView(frame: JJCGRectMake(x: 0, y: 56, width: 227, height: 130))
        self.errorLabel = UILabel(frame: CGRect(x: 0, y: noNetImageView.bottom + JJAdapter(174), width: frame.size.width, height: JJAdapter(17)))
        self.retryButton = UIButton(frame: CGRect(x: 0, y: errorLabel.bottom + JJAdapter(20), width: JJAdapter(255), height: JJAdapter(45)))
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        noNetImageView.center = CGPoint(x: self.center.x, y: noNetImageView.center.y)
        noNetImageView.image = UIImage(named: "icon_zixun_nonet")
        
        errorLabel.center = CGPoint(x: self.center.x, y: errorLabel.center.y)
        errorLabel.textAlignment = .center
        if let errorTextColor = self.errorTextColor {
            errorLabel.textColor = errorTextColor
        } else {
            errorLabel.textColor = UIColor(valueRGB: 0x999999, alpha: 1)
        }
        if let errorFont = self.errorFont {
            errorLabel.font = errorFont
        } else {
            errorLabel.font = UIFont.systemFont(ofSize: CGFloat(adValue: 17))
        }

        retryButton.center = CGPoint(x: self.center.x, y: retryButton.center.y)
        retryButton.backgroundColor = UIColor(valueRGB: 0x4285f4, alpha: 1)
        retryButton.setTitle("重新加载，更多精彩", for: .normal)
        retryButton.setTitleColor(UIColor(valueRGB: 0xffffff, alpha: 1), for: .normal)
        retryButton.layer.cornerRadius = 3.0
        retryButton.addTarget(self, action: #selector(retryButtonClicked(sender:)), for: .touchUpInside)

        self.addSubview(noNetImageView)
        self.addSubview(errorLabel)
        self.addSubview(retryButton)
    }

    internal func show(errorMessage: String, retryClosure: (() -> Void)?) {
        errorLabel.text = errorMessage
        self.retryClosure = retryClosure
        self.isHidden = false
    }

    internal func hide() {
        self.isHidden = true
    }

    @objc private func retryButtonClicked(sender: UIButton) {
        if let retryClosure = self.retryClosure {
            retryClosure()
        }
    }
}
