//
//  UIColor-Extension.swift
//  FirebaseTestApp
//
//  Created by AGA TOMOHIRO on 2020/06/18.
//  Copyright © 2020 AGA TOMOHIRO. All rights reserved.
//

import UIKit

extension UIColor{
    static func rgb(red: CGFloat,green: CGFloat,blue:CGFloat) -> UIColor{
        return self.init(red:red/255, green: green/255, blue: blue/255,alpha: 1)
    }
}
