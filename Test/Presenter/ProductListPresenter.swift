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
    var showTableView = false
    
    //MARK:- initilization for presenter
    func setPresenterPreference(){
        self.viewParent?.productTableView.delegate = self
        self.viewParent?.productTableView.dataSource = self
        self.viewParent?.productTableView.dropDelegate = self
        self.viewParent?.productTableView.dragDelegate = self
        self.viewParent?.productTableView.dragInteractionEnabled = true
        getProductList()
        self.viewParent?.switchView.addTarget(self, action: #selector(switchTapped(sender:)), for: .touchUpInside)
    }
    
    @objc func switchTapped(sender: UISwitch){
       self.showTableView = sender.isOn == true ? false : true
        self.viewParent?.productTableView.reloadData()
    }
}

extension ProductListPresenter: UITableViewDelegate, UITableViewDataSource{
    //MARK:- table view dataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrCategoryName.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showTableView == true{
            return self.groupedArr[self.arrCategoryName[section]]?.count ?? 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.showTableView == true{ /// for table view cell
            guard let cell = self.viewParent?.productTableView.dequeueReusableCell(withIdentifier: "productSingleCell") as? productSingleCell else{return UITableViewCell()}
            let ent = self.groupedArr[self.arrCategoryName[indexPath.section]]
            cell.lblProductName.text = ent?[indexPath.row].name
            return cell
        }
        
        ///for collection view cell
        guard let cell = self.viewParent?.productTableView.dequeueReusableCell(withIdentifier: "productTblCell") as? productTblCell else{return UITableViewCell()}
                   cell.productListCollectionView.tag = indexPath.section
                   cell.productListCollectionView.delegate = self
                   cell.productListCollectionView.dataSource = self
                   cell.productListCollectionView.dragDelegate = self
                   cell.productListCollectionView.dropDelegate = self
                   cell.productListCollectionView.reloadData()
        cell.productListCollectionView.dragInteractionEnabled = true
        return cell
    }
    
    //MARK:- table view delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.showTableView == true{
            if self.arrHeaderSelection[indexPath.section].sectionExpanded == true{
                 return 40
            }
            return 0
        }
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
        
        headerView.FilterView.isHidden = self.showTableView == true ? true : false
        headerView.dropDownView.isHidden = self.showTableView == true ? false : true
        
        headerView.btnDownArrow.tag = section
        headerView.dropDownImg.image = self.arrHeaderSelection[section].sectionExpanded == true ? UIImage(imageLiteralResourceName: "down") : UIImage(imageLiteralResourceName: "right")
        headerView.btnDownArrow.addTarget(self, action: #selector(dropDownTapped(sender:)), for: .touchUpInside)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.groupedArr[self.arrCategoryName[indexPath.section]]?[indexPath.row])
    }
}

extension ProductListPresenter: UITableViewDragDelegate, UITableViewDropDelegate{
    //MARK:- table view drag and drop delegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.groupedArr[self.arrCategoryName[indexPath.section]]?[indexPath.item]
        let itemProvider = NSItemProvider(item: item as? NSSecureCoding, typeIdentifier: item?.name)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView,
           dropSessionDidUpdate session: UIDropSession,
           withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal{
           if tableView.hasActiveDrag{
               return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
           }
           return UITableViewDropProposal(operation: .forbidden)
       }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        var destinationIndexPath = IndexPath()
        if let indexPath = coordinator.destinationIndexPath{
            destinationIndexPath = indexPath
        }else{
            let row = tableView.numberOfRows(inSection: 0)
            destinationIndexPath = IndexPath(row: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move{
            self.reorderItemsTableView(coordinator: coordinator, destinationPath: destinationIndexPath, tableView: tableView, section: destinationIndexPath.section)
        }
    }
    
    fileprivate func reorderItemsTableView(coordinator:UITableViewDropCoordinator, destinationPath: IndexPath, tableView: UITableView, section: Int){
        
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath{
            tableView.performBatchUpdates({
                self.groupedArr[self.arrCategoryName[section]]?.remove(at: sourceIndexPath.item)
                self.groupedArr[self.arrCategoryName[section]]?.insert(item.dragItem.localObject as! product, at: destinationPath.item)
                tableView.deleteRows(at: [sourceIndexPath], with: UITableView.RowAnimation.automatic)
                tableView.insertRows(at: [destinationPath], with: UITableView.RowAnimation.automatic)
                
            }, completion: nil)
            coordinator.drop(item.dragItem, toRowAt: destinationPath)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.groupedArr[self.arrCategoryName[collectionView.tag]]?[indexPath.item])
    }
}

extension ProductListPresenter: UICollectionViewDropDelegate,UICollectionViewDragDelegate{
    //MARK:- collection view drag and drop delegate
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath = IndexPath()
        if let indexPath = coordinator.destinationIndexPath{
            destinationIndexPath = indexPath
        }else{
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(row: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move{
            self.reorderItems(coordinator: coordinator, destinationPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal{
        if collectionView.hasActiveDrag{
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.groupedArr[self.arrCategoryName[collectionView.tag]]?[indexPath.item]
        let itemProvider = NSItemProvider(item: item as? NSSecureCoding, typeIdentifier: item?.name)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    fileprivate func reorderItems(coordinator:UICollectionViewDropCoordinator, destinationPath: IndexPath, collectionView: UICollectionView){
        
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath{
            collectionView.performBatchUpdates({
                self.groupedArr[self.arrCategoryName[collectionView.tag]]?.remove(at: sourceIndexPath.item)
                self.groupedArr[self.arrCategoryName[collectionView.tag]]?.insert(item.dragItem.localObject as! product, at: destinationPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationPath])
                
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationPath)
        }
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
                    let computeArray: Array<headerSelected> = Array(repeating: ent, count: self.arrCategoryName.count)
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
    
    ///btn drop down tapped in header view
    @objc func dropDownTapped(sender: UIButton){
        for (index,_) in self.arrHeaderSelection.enumerated(){
            if index == sender.tag{
                self.arrHeaderSelection[index].sectionExpanded = !self.arrHeaderSelection[index].sectionExpanded!
            }else{
                self.arrHeaderSelection[index].sectionExpanded = false
            }
        }
        self.viewParent?.productTableView.reloadData()
    }
}

//MARK:- Sequence extension
extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
