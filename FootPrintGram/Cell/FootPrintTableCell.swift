//
//  FootPrintTableCell.swift
//  FootPrintGram
//
//  Created by 정하민 on 19/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import UIKit

class FootPrintTableCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
