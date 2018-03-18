//
//  UIColorConvenience.swift
//  FTSearchController
//
//  Created by 王俊硕 on 2018/3/18.
//  Copyright © 2018年 王俊硕. All rights reserved.
//

import UIKit

extension UIColor {
   
    convenience init(hex: Int) {
        let r = (hex & 0xff0000) >> 16
        let g = (hex & 0x00ff00) >> 8
        let b = hex & 0x0000ff
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }
}
