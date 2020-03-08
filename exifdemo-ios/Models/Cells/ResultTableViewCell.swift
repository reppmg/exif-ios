//
//  ResultTableViewCell.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 07/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet var usersPhotoLabel: UILabel!
    @IBOutlet var coordinatesLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
