//
//  VMapBottomToolViewDelegate.swift
//  VMap
//
//  Created by Admin on 5/15/24.
//

import Foundation

protocol VMapBottomToolViewDelegate: NSObject {
    
    func directionsDidClick()
    func cleanDidClick()
    
    func startNavigation()
    func exitNavigation()
    
    func switchNavigationView()
}
