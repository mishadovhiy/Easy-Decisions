//
//  ValuesViewController.swift
//  Decisions
//
//  Created by Misha Dovhiy on 11.06.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

class ValuesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var tableData = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func getData() {
        brain.loadItems()
        
        tableData.removeAll()
        for i in 0..<brain.allData.count {
            if !tableData.contains(brain.allData[i].title ?? "") {
                tableData.append(brain.allData[i].title ?? "")
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ValuesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return tableData.count
        case 1: return 1
        default:
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ValuesVCCell", for: indexPath) as! ValuesVCCell
        cell.cellSetup(tableData: tableData, i: indexPath.row)
        if indexPath.section == 1 {
            cell.titleLabel.text = "New"
            cell.valuesLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            selectedCategory = tableData[indexPath.row]
            self.performSegue(withIdentifier: "quite", sender: self)
        case 1:
            selectedCategory = "New"
            self.performSegue(withIdentifier: "quite", sender: self)
        default:
            print("New")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                
                brain.deleteData(with: self.tableData[indexPath.row])
                DispatchQueue.main.async {
                    self.getData()
                }
            }
            deleteAction.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
}

class ValuesVCCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valuesLabel: UILabel!
    
    func cellSetup(tableData: [String], i: Int) {
        if tableData.count > 0 {
            let data = tableData[i]
            
            titleLabel.text = data
            valuesLabel.text = ""
            for i in 0..<brain.allData.count {
                if brain.allData[i].title == data {
                    if valuesLabel.text != "" {
                        valuesLabel.text = (valuesLabel.text ?? "") + ", " + (brain.allData[i].value ?? "")
                    } else {
                        valuesLabel.text = brain.allData[i].value ?? ""
                    }
                    
                }
            }
        }
    }
}
