//
//  NLRestaurantCell.swift
//  NoteworthLunch
//
//  Created by Jesse Tello on 7/11/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit

class NLRestaurantCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
