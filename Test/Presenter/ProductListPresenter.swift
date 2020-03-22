//
//  ProductListPresenter.swift
//  Test
//
//  Created by Ghous Ansari on 21/03/20.
//  Copyright © 2020 Ghous Ansari. All rights reserved.
//

import Foundation
import UIKit

class ProductListPresenter: NSObject{
    
    //MARK:- declaring variable
    var viewParent : ProductListVC?
    var groupedArr = [String?:[product]]()
    var arrHeaderSelection = [headerSelected]()
    var arrCategoryName = [String]()
    
    //MARK:- initilization for presenter
    func setPresenterPreference(){
        self.viewParent?.productTableView.delegate = self
        self.viewParent?.productTableView.dataSource = self
        getProductList()
    }
}

extension ProductListPresenter: UITableViewDelegate, UITableViewDataSource{
    //MARK:- table view dataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrCategoryName.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.viewParent?.productTableView.dequeueReusableCell(withIdentifier: "productTblCell") as? productTblCell else{return UITableViewCell()}
        cell.productListCollectionView.tag = indexPath.section
        cell.productListCollectionView.delegate = self
        cell.productListCollectionView.dataSource = self
        cell.productListCollectionView.reloadData()
        return cell
    }
    
    //MARK:- table view delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = CustomTopView()
        headerView.lblProductName.text = self.arrCategoryName[section] + ":"
        headerView.btnName.tag = section
        headerView.btnPrice.tag = section
        headerView.btnPrice.accessibilityHint = "Price"
        headerView.btnName.accessibilityHint = "Name"
        headerView.btnPrice.addTarget(self, action: #selector(priceNameTapped(sender:)), for: .touchUpInside)
        headerView.btnName.addTarget(self, action: #selector(priceNameTapped(sender:)), for: .touchUpInside)
        
        headerView.btnPrice.backgroundColor = self.arrHeaderSelection[section].isPriceSelected == true ? UIColor.white : UIColor.clear
        headerView.btnPrice.setTitleColor(self.arrHeaderSelection[section].isPriceSelected == true ? UIColor.black : UIColor.systemBlue, for: .normal)
        
        headerView.btnName.backgroundColor = self.arrHeaderSelection[section].isNameSelected == true ? UIColor.white : UIColor.clear
        headerView.btnName.setTitleColor(self.arrHeaderSelection[section].isNameSelected == true ? UIColor.black : UIColor.systemBlue, for: .normal)
        return headerView
    }
}

extension ProductListPresenter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK:- collection view delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 8, height: collectionView.frame.height / 2 - 10)
    }
    
    //MARK:- colletionv view datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groupedArr[self.arrCategoryName[collectionView.tag]]?.count ?? 0
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productListColCell", for: indexPath) as? productListColCell else{return UICollectionViewCell()}
        let ent = self.groupedArr[self.arrCategoryName[collectionView.tag]]
        cell.lblProductName.text = ent?[indexPath.item].name
        return cell
       }
    
}

extension ProductListPresenter{
    //MARK:- Web Services
    
    /// Description:- get list of Product data from api
    func getProductList(){
        
        let request = RequestManager()
        
        request.requestCommonMethod(strAPIName: GAUrlConstants.BaseURl, strParameterName: ["" : ""], strMethod: .GET) { (data, isSuccess, err) in
            if isSuccess == true{
                
                guard let jsonData = data as? Data else{return}
                do{
                    let products = try? JSONDecoder()
                        .decode([BaseDecodable<productList>].self, from: jsonData)
                        .compactMap { $0.base }

                    guard let productArr = products else{return}
                    var arrProductList = [product]()
                    for obj in  productArr{
                        for ent in obj.products{
                            self.arrCategoryName.append(obj.name ?? "")
                            arrProductList.append(product(sku: ent.sku, name: ent.name, cost: ent.cost, category: obj.name))
                        }
                    }
                    
                    self.arrCategoryName = Array(Set(self.arrCategoryName.sorted()))
                    self.groupedArr = arrProductList.group(by: { $0.category })
                    
                    let ent = headerSelected(showTablView: false, sectionExpanded: false, section: nil, isPriceSelected: false, isNameSelected: false)
                    var computeArray: Array<headerSelected> = Array(repeating: ent, count: self.arrCategoryName.count)
                    self.arrHeaderSelection = computeArray
                    
                    DispatchQueue.main.async {
                        self.viewParent?.productTableView.reloadData()
                    }
                }catch{
                    print("Error while decoding the json")
                }
                //var arrModel = self.movieListArr?.results.map({return dashBoardVM(movie: $0)}) ?? []
            }else{
                print(err)
            }
        }
    }
    
    //MARK:- custom function and methods
    @objc func priceNameTapped(sender: UIButton){
        self.groupedArr[self.arrCategoryName[sender.tag]] = sender.accessibilityHint == "Price" ? self.groupedArr[self.arrCategoryName[sender.tag]]?.sorted(by: { (lhs, rhs) -> Bool in return (lhs.cost ?? 0) < (rhs.cost ?? 0) }) : self.groupedArr[self.arrCategoryName[sender.tag]]?.sorted(by: { (lhs, rhs) -> Bool in return (lhs.name ?? "") < (rhs.name ?? "") })
        self.arrHeaderSelection[sender.tag].isPriceSelected = sender.accessibilityHint == "Price" ? true : false
        self.arrHeaderSelection[sender.tag].isNameSelected = sender.accessibilityHint == "Name" ? true : false
        self.viewParent?.productTableView.reloadSections([sender.tag], with: .automatic)
        
    }
}

//MARK:- Sequence extension
extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
