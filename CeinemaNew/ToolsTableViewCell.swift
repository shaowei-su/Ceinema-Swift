//
//  ToolsTableViewCell.swift
//  CeinemaNew
//
//  Created by shaowei on 7/13/15.
//  Copyright (c) 2015 shaowei. All rights reserved.
//

import UIKit

class ToolsTableViewCell: UITableViewCell {

    @IBOutlet weak var toolTitle: UILabel!
    @IBOutlet weak var toolPostingDate: UILabel!
    @IBOutlet weak var toolPublisher: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
