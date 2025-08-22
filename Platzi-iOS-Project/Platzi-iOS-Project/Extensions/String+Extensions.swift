//
//  String+Extensions.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import Foundation

extension String {
    
    var checkForEmptyOrWhitespace: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var isValidPassword: Bool {
        self.count >= 8
    }
    
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z•_%+-]+@[A-Za-z0-9.-1+\\. [A-Za-z]{2, }"
        return self.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
