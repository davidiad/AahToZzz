//
//  ProgressTableCell.swift
//  AahToZzz
//
//  Created by David Fierstein on 10/25/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class ProgressTableCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsets.zero;
        self.preservesSuperviewLayoutMargins = false;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
