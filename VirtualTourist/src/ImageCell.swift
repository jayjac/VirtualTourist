//
//  ImageCell.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 18/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    func setupCell(with data: Data?, title: String?) {
        activityIndicator.hidesWhenStopped = true
        if let data = data {
            imageView.image = UIImage(data: data)
            label.text = title
            activityIndicator.stopAnimating()
        } else {
            imageView.image = UIImage(named: "placeholder")
            label.text = ""
            activityIndicator.startAnimating()
        }
    }
    
    
}
