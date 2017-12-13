//
//  SinglePhotoViewController.swift
//  VirtualTourist
//
//  Created by Jay Jac on 13/12/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit

class SinglePhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var photoData: Data?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let data = photoData else { return }
        imageView.image = UIImage(data: data)
    }


    



}
