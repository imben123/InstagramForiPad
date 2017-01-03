//
//  MediaListWebStore.swift
//  InstagramData
//
//  Created by Ben Davis on 31/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

protocol MediaListWebStore {
    func fetchNewestMedia(_ completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?, failure: (()->())?)
    func fetchMedia(after endCursor: String, completion: ((_ newMedia: [MediaItem], _ endCursor: String?)->())?, failure: (()->())?)
}
