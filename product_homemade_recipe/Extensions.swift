//
//  Extensions.swift
//  product_homemade_recipe
//
//  Created by M'haimdat omar on 09-09-2020.
//

import UIKit

extension UIViewController {
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
}

extension UIViewController {
    func parse(jsonData: Data) -> [Product]? {
        do {
            let decodedData = try JSONDecoder().decode([Product].self, from: jsonData)
            return decodedData
        } catch {
            print("decode error")
        }
        return nil
    }
}
