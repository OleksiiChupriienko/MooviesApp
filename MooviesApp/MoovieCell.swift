//
//  MoovieCell.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 10.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class MoovieCell: UITableViewCell {
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var labelsBackgroundView: UIView!
    @IBOutlet weak var moovieTitleLabel: UILabel!
    @IBOutlet weak var moovieReleaseYearTitle: UILabel!
    @IBOutlet weak var moovieRatingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterView.layer.cornerRadius = 3.3
        
        labelsBackgroundView.layer.cornerRadius = 3.3
        labelsBackgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        labelsBackgroundView.layer.shadowOffset = .init(width: 2, height: 2)
        labelsBackgroundView.layer.shadowRadius = 2
        labelsBackgroundView.layer.shadowOpacity = 1
    }
    
}
