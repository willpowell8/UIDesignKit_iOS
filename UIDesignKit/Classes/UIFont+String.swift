//
//  UIFont+String.swift
//  Pods
//
//  Created by Will Powell on 15/12/2016.
//
//

import Foundation
import UIKit

extension UIFont {
    func toDesignString() -> String {
        return "\(self.fontName)|\(self.familyName)|\(self.pointSize)"
    }
}
