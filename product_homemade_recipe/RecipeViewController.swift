//
//  RecipeViewController.swift
//  product_homemade_recipe
//
//  Created by M'haimdat omar on 09-09-2020.
//

import UIKit

class RecipeViewController: UIViewController {
    
    lazy var recipe = [RecipeItem]()
    
    private let cellId = "cellId"
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.clear
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = true
        table.showsVerticalScrollIndicator = false
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        view.backgroundColor = .black
        setupTableView()
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .systemBackground
        } else {
            tableView.backgroundColor = .white
        }
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
}

extension RecipeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: cellId) else {
            return UITableViewCell()
        }
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        cell.textLabel?.text = String(self.recipe[indexPath.row].quantity)
        cell.detailTextLabel?.text = self.recipe[indexPath.row].product
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.textColor = .label
        return cell
    }
    
}
