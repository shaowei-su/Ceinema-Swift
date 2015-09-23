//
//  AllTableViewCell.swift
//  CeinemaNew
//
//  Created by shaowei on 7/6/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit

/// Contains the prototype info of lecture table view
class AllTableViewCell: UITableViewCell {
    

    /// Lecture image thumbnail outlet
    @IBOutlet weak var mediaImage: UIImageView!
    /// Lecture title label outlet
    @IBOutlet weak var mediaTitle: UILabel!
    /// Lecture presentor label outlet
    @IBOutlet weak var mediaPresentor: UILabel!
    /// Lecture date label outlet
    @IBOutlet weak var mediaDate: UILabel!
    /// Lecture ribbon tag that applies to latest released 
    @IBOutlet weak var mediaNewTag: UIImageView!

}
