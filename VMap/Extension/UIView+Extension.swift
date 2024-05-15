//
//  UIViewExtension.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import UIKit

fileprivate let safeAreaInsets = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets


let bottomSafeHeight = safeAreaInsets?.bottom ?? 0
let topSafeHeight = safeAreaInsets?.top ?? 0

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
