//
//  UIString+UIDesign.swift
//  Pods
//
//  Created by Will Powell on 23/12/2016.
//
//

import Foundation

extension String {
    var isDesignStringAcceptable: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9.]", options: .regularExpression) == nil
    }
}
