//
//  labelCollectionViewCell.swift
//  proTodo
//
//  Created by 성다연 on 2021/04/17.
//  Copyright © 2021 성다연. All rights reserved.
//

import UIKit

class labelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagButton: UIButton! {
        didSet {
            tagButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        }
    }
    
    static let CellID = "labelCollectionViewCell"
    
    func bindViewModel(tag : Tag){
        tagButton.backgroundColor = UIColor.colorRGBHex(hex: tag.color)
        tagButton.setTitle(" " + tag.name + "    ", for: .normal)
    }
}