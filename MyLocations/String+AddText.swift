//
//  String+AddText.swift
//  MyLocations
//
//  Created by Anatoliy Chernyuk on 11/22/17.
//  Copyright © 2017 Anatoliy Chernyuk. All rights reserved.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
