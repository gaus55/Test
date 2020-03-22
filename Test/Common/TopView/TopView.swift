//
//  TopView.swift
//  Fintoo
//
//  Created by Ghous Ansari on 23/02/20.
//  Copyright © 2020 Ghous Ansari. All rights reserved.
//

import Foundation
import UIKit

class TopView: UIView{
    
    //MARK:- referencing outlet
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    
    //MARK:- common init setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("TopView", owner: self, options: nil)
        addSubview(contentView)
    }
    
}
