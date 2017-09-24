//
//  CarTableViewCell.swift
//  Bio
//
//  Created by Hery Ratsimihah on 9/23/17.
//  Copyright © 2017 Ratsimihah. All rights reserved.
//

import SnapKit
import UIKit

class CarTableViewCell: UITableViewCell {

    let carLabel = UILabel()
    let speedLabel = UILabel()
    let statusLabel = UIButton()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setUpUI() {
        self.contentView.addSubview(self.carLabel)
        self.carLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView).inset(15)
            make.left.equalTo(self.contentView).inset(20)
        }

        self.contentView.addSubview(self.speedLabel)
        self.speedLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView).offset(-20)
            make.centerY.equalTo(self.contentView)
        }

        self.prepareButton(self.statusLabel, with: UIColor.lightGray)
        self.contentView.addSubview(self.statusLabel)
        self.statusLabel.setTitle("STOPPED", for: .normal)
        self.statusLabel.isUserInteractionEnabled = false
        self.statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.carLabel.snp.bottom).offset(5)
            make.left.equalTo(self.carLabel)
        }
    }

    func prepareButton(_ button:UIButton, with color:UIColor) {
        button.backgroundColor = color
        button.layer.borderColor = UIColor.darkGrey().cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        button.layer.cornerRadius = 3.0
        button.contentEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7)
    }
}
