//
//  CustomTopView
//  Researchbytes
//
//  Created by Vivek Gajbe on 1/28/20.
//  Copyright © 2020 vivek G. All rights reserved.

import UIKit

/// class to show top view on each viewcontroller
class CustomTopView: UIView {
    
    //MARK:- Outlets
    @IBOutlet var viwContent: UIView!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var lblProductName: UILabel!
    
    var bIsDisplayMenuOption = true
    
    
    //MARK:- View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    //MARK:- User defined functions
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    func commonInit() {
        // Drawing code
        Bundle.main.loadNibNamed("CustomTopView", owner: self, options: nil)
        addSubview(viwContent)
        viwContent.frame = self.bounds
    }

}

