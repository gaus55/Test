//
//  ProductDetailsVC.swift
//  Test
//
//  Created by Ghous Ansari on 22/03/20.
//  Copyright © 2020 Ghous Ansari. All rights reserved.
//

import UIKit
import SDWebImage
import TOCropViewController

class ProductDetailsVC: UIViewController,TOCropViewControllerDelegate{
    //MARK:- referencing outlets
    @IBOutlet weak var imgView : UIImageView!
    
    //MARK:- Declaring variable
    var strImgPath = ""
    var imageCache = SDImageCache()
    
    //MARK:- View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setControllerPreference()
    }
    
    //MARK:- custom function
    func setControllerPreference(){
        imgView.sd_setImage(with: URL(string: strImgPath), placeholderImage: UIImage(named: "book.png"))
        let logoutBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(presentCropViewController))
        self.navigationItem.rightBarButtonItem  = logoutBarButtonItem
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImageView))
        imgView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc public func didTapImageView() {
        // When tapping the image view, restore the image to the previous cropping state
        guard let imgs = self.imgView.image else{return}
        let cropViewController = TOCropViewController(croppingStyle: .default, image: imgs)
        cropViewController.delegate = self
        let viewFrame = view.convert(imgView.frame, to: navigationController!.view)
        cropViewController.presentAnimatedFrom(self, view: self.view, frame: self.view.bounds, setup: {
            self.imgView.isHidden = true
        }, completion: nil)
    }
    
    @objc func presentCropViewController() {
        let image: UIImage? = imgView.image
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image!)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true) {
            self.imgView.isHidden = false
            self.imgView.image = image
            SDImageCache.shared.store(image, forKey: self.strImgPath)
            NotificationCenter.default.post(name: NSNotification.Name("imageEdited"), object: nil)
//            self.imageCache.queryImage(forKey: self.strImgPath, options: SDWebImageOptions.fromCacheOnly, context: [SDWebImageContextOption.cacheKeyFilter : SDImageScaleFactorForKey]) { (img, data, SDImageCacheType) in
//                SDImageCache.shared.store(image, forKey: self.strImgPath)
//            }
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        self.dismiss(animated: true) {
            self.imgView.isHidden = false
        }
    }
}
