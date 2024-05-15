//
//  StringExtension.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import UIKit

extension String {
    /// filter Chinese
    var filterChinese: String {
        let newText = self.replacingOccurrences(of: "\n", with: " ")
        let pattern = "[\\u4E00-\\u9FA5]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: newText.utf16.count)
        let result = regex.stringByReplacingMatches(in: newText, options: [], range: range, withTemplate: "")
        if result.count == 0 {
            return self
        }
        return result
    }
}

extension String {
    var image: UIImage? {
        return UIImage(named: self)
    }
}
