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
    @IBOutlet var placeholderImageView: UIImageView!
    
    
    func setupCell(with data: Data?, title: String?) {
        activityIndicator.hidesWhenStopped = true
        if let data = data {
            placeholderImageView.isHidden = true
            imageView.image = UIImage(data: data)
            label.text = title
            activityIndicator.stopAnimating()
        } else {
            placeholderImageView.isHidden = false
            placeholderImageView.image = UIImage(named: "placeholder")
            imageView.image = nil
            label.text = ""
            activityIndicator.startAnimating()
        }
    }
    
    
}
