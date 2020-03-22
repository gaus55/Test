//
//  ProductModel.swift
//  Test
//
//  Created by Ghous Ansari on 21/03/20.
//  Copyright © 2020 Ghous Ansari. All rights reserved.
//

import Foundation

struct BaseDecodable<Base : Decodable> : Decodable {

    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

struct productList: Decodable{
    let name: String?
    let products: [product]
    
}

struct product: Decodable{
    let sku: Int?
    let name: String?
    let cost: Int?
    let category: String?
}

struct headerSelected{
    let showTablView: Bool?
    let sectionExpanded: Bool?
    let section: Int?
    var isPriceSelected: Bool?
    var isNameSelected: Bool?
}
