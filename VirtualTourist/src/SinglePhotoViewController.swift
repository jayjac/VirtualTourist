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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let data = photoData else { return }
        imageView.image = UIImage(data: data)
    }


    



}
