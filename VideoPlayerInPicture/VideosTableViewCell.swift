//
//  VideosTableViewCell.swift
//  VideoPlayerInPicture
//
//  Created by Harish Kumar on 09/04/19.
//  Copyright © 2019 Harish Kumar. All rights reserved.
//

import UIKit

class VideosTableViewCell: UITableViewCell {

    @IBOutlet var Thumbnail: UIImageView!
    @IBOutlet var VideoTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
