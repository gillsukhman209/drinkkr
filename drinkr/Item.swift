//
//  Item.swift
//  drinkr
//
//  Created by Sukhman Singh on 8/14/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
