//
//  VideoInfo.swift
//  VideoPlayerInPicture
//
//  Created by Harish Kumar on 09/04/19.
//  Copyright © 2019 Harish Kumar. All rights reserved.
//

import Foundation

class VideoInfo: NSObject {
    
    var VideoTitle : String
    var VideoURL : String
    var PublicationDate : String
    var ImageURL : String
    
    init(VideoTitle: String, VideoURL: String, PublicationDate : String, ImageURL : String) {
        self.VideoTitle = VideoTitle
        self.VideoURL = VideoURL
        self.PublicationDate = PublicationDate
        self.ImageURL = ImageURL
    }
    
}
