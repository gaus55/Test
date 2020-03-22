//
//  ProductListVC.swift
//  Test
//
//  Created by Ghous Ansari on 21/03/20.
//  Copyright © 2020 Ghous Ansari. All rights reserved.
//

import UIKit

class ProductListVC: UIViewController {

    //MARK:- referencing outlets
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var switchView: UISwitch!
    
    //MARK:- declaring variable
    lazy var presenter = ProductListPresenter()
    
    //MARK:- View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setControllerPreference()
    }

    //MARK:- set controller Preference
    func setControllerPreference(){
        self.productTableView.tableFooterView = UIView()
        presenter.viewParent = self
        presenter.setPresenterPreference()
        self.title = "PRODUCTS"
    }
}

//MARK:- Table View Cell
class productTblCell: UITableViewCell{
    @IBOutlet weak var productListCollectionView: UICollectionView!
}

///for table view cell for single product
class productSingleCell: UITableViewCell{
    @IBOutlet weak var lblProductName: UILabel!
     @IBOutlet weak var imgView: UIImageView!
}

//MARK:- productList CollectionView cell
class productListColCell:UICollectionViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
}
