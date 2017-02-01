//
//  AppConstants.swift
//  Translate
//
//  Created by Alexey Papin on 01.02.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import Foundation
import UIKit

enum AppFont {
    case sanFranciscoDisplayRegular(size: CGFloat)
    case sanFranciscoDisplayMedium(size: CGFloat)
    case sanFranciscoDisplayBold(size: CGFloat)
    
    var font: UIFont {
        switch self {
        case .sanFranciscoDisplayRegular(let size): return UIFont(name: "SanFranciscoDisplay-Regular", size: size)!
        case .sanFranciscoDisplayMedium(let size): return UIFont(name: "SanFranciscoDisplay-Medium", size: size)!
        case .sanFranciscoDisplayBold(let size): return UIFont(name: "SanFranciscoDisplay-Bold", size: size)!
        }
    }
}
