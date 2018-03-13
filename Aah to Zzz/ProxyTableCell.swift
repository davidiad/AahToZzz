//
//  ProxyTableCell.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/16/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//


import UIKit

class ProxyTableCell: UITableViewCell {
    
    
    @IBOutlet weak var bg: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bg?.image = UIImage(named: "icon_newlist")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
