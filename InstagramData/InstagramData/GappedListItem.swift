//
//  GappedListItem.swift
//  InstagramData
//
//  Created by Ben Davis on 28/03/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation

enum GappedListItem {
    case item(id: String)
    case gap(gapCursor: String?)
}

extension GappedListItem: Equatable {
    
    public static func ==(_ lhs: GappedListItem, rhs: GappedListItem) -> Bool {
        
        switch (lhs, rhs) {
            
        case (let .item(lhsId), let .item(rhsId)):
            return lhsId == rhsId
            
        case (let .gap(lhsGapCursor), let .gap(rhsGapCursor)):
            return lhsGapCursor == rhsGapCursor
            
        default:
            return false
            
        }
    }
}

extension GappedListItem {
    
    init(id: String) {
        self = .item(id: id)
    }
    
    init(gapCursor: String?) {
        self = .gap(gapCursor: gapCursor)
    }
    
    var isGap: Bool {
        switch self {
        case .gap:
            return true
        default:
            return false
        }
    }
    
    var gapCursor: String? {
        switch self {
        case let .gap(gapCursor):
            return gapCursor
        default:
            return nil
        }
    }
    
    var id: String? {
        switch self {
        case let .item(id):
            return id
        default:
            return nil
        }
    }
}
