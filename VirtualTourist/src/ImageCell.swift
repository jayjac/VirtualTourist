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
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var deleteImageViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var overlayView: UIView!
    

    
    
    func setupCell(with data: Data?, title: String?, deletingMode: Bool) {
        activityIndicator.hidesWhenStopped = true
        deleteImageViewTrailingConstraint.constant = deletingMode ? 5.0 : -30.0
        setupOverlay(deletingMode)
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
    
    private func setupOverlay(_ deletingMode: Bool) {
        overlayView.isHidden = !deletingMode
    }
    
    func toggleDeleteImage(_ deletingMode: Bool) {
        deleteImageViewTrailingConstraint.constant = deletingMode ? 5.0 : -30.0
        setupOverlay(deletingMode)
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    
}
