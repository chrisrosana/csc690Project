//
//  SearchCell.swift
//  JamSesh
//
//  Created by Micaella Morales on 4/19/19.
//  Copyright © 2019 Monali Chuatico. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
