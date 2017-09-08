//
//  JJTextInsetsLabel.swift
//  JJSwiftDemo
//
//  Created by Mr.JJ on 2017/5/27.
//  Copyright © 2017年 yejiajun. All rights reserved.
//

import UIKit

/// 内边距Label
class JJTextInsetsLabel: UILabel {

    private var textInsets: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    internal init(frame: CGRect, textInsets: UIEdgeInsets) {
        self.textInsets = textInsets
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }

}
