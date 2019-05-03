//
//  WordTableViewCell.swift
//  WordScapeSolver
//
//  Created by 汤逸凡 on 2019/5/1.
//  Copyright © 2019 汤逸凡. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
