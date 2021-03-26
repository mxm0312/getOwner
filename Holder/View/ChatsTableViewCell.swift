//
//  ChatTableViewCell.swift
//  Holder
//
//  Created by Maxim Perehod on 08.02.2021.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet var userProfileImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var lastMessage: UILabel!
    @IBOutlet var roundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
