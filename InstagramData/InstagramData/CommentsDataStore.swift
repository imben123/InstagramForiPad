//
//  CommentsDataStore.swift
//  InstagramData
//
//  Created by Ben Davis on 04/02/2017.
//  Copyright © 2017 bendavisapps. All rights reserved.
//

import Foundation
import RealmSwift

class CommentsDataStore {
    
    private let backgroundQueue = DispatchQueue(label: "uk.co.bendavisapps.CommentsDataStore", qos: .background)
    
    func archiveComments(_ comments: [MediaItemComment]) {
        backgroundQueue.async {
            let realm = try! Realm()
            
            realm.beginWrite()
            
            for comment in comments {
                let commentRow = MediaItemCommentTableRow(comment)
                realm.add(commentRow, update: .all)
            }
            
            try? realm.commitWrite()
        }
    }
    
    func loadComment(with id: String, completion: @escaping (_ comment: MediaItemComment?) -> Void) {
        backgroundQueue.async {
            let realm = try! Realm()
            let commentRow = realm.objects(MediaItemCommentTableRow.self).filter("id = '\(id)'").first
            if let commentRow = commentRow {
                completion(MediaItemComment(commentRow))
            } else {
                completion(nil)
            }
        }
    }
    
//    func loadMediaItems(with ids: [String], completion: @escaping (_ media: [MediaItem]) -> Void) {
//        backgroundQueue.async {
//            let realm = try! Realm()
//            var first = true
//            let idsString = ids.reduce("", { (result, id) -> String in
//                if first {
//                    first = false
//                    return result + "'\(id)'"
//                } else {
//                    return result + ",'\(id)'"
//                }
//            })
//            let mediaItemRows = realm.objects(MediaItemTableRow.self).filter("id IN {\(idsString)}")
//            let result: [MediaItem] = mediaItemRows.map({ MediaItem($0) })
//            completion(result)
//        }
//    }
//    
//    func unarchiveMedia(_ completion: @escaping (_ media: [MediaItem]) -> Void) {
//        
//        backgroundQueue.async {
//            
//            let realm = try! Realm()
//            
//            let mediaItemRows = realm.objects(MediaItemTableRow.self)
//            
//            var media: [MediaItem] = []
//            for mediaItemRow in mediaItemRows {
//                media.append(MediaItem(mediaItemRow))
//            }
//            
//            completion(media)
//        }
//    }
    
}
