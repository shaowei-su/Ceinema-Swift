//
//  AllTableViewCell.swift
//  CeinemaNew
//
//  Created by shaowei on 7/6/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit

class AllTableViewCell: UITableViewCell {
    

    
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var mediaTitle: UILabel!

    @IBOutlet weak var mediaPresentor: UILabel!
    @IBOutlet weak var mediaDate: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
