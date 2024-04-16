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
    @IBOutlet weak var closeButton: UIButton!
    var tableData = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
        tableView.delegate = self
        tableView.dataSource = self
        closeButton.layer.cornerRadius = 6
        
        let hideKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeSwiped))
        hideKeyboardGesture.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hideKeyboardGesture)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(closeVCSwipe(sender:)), for: UIControl.Event.valueChanged)
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.clear
        tableView.addSubview(refreshControl)
        
    }
    
    @objc func closeVCSwipe(sender:AnyObject) {
        closePressed(closeButton)
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
    
    @objc func closeSwiped(_ sender: UISwipeGestureRecognizer? = nil) {
        closePressed(closeButton)
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
        
        if indexPath.section != 1 {
            cell.cellBackgroundView.backgroundColor = Colors.lightGrey
            cell.titleLabel.textAlignment = .left
        } else {
            cell.cellBackgroundView.backgroundColor = Colors.lightYellow
            cell.titleLabel.textAlignment = .center
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
                
                self.brain.deleteData(with: self.tableData[indexPath.row])
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
    @IBOutlet weak var cellBackgroundView: UIView!
    
    func cellSetup(tableData: [String], i: Int) {
        if tableData.count > 0 {
            let data = tableData[i]
            
            cellBackgroundView.layer.masksToBounds = true
            cellBackgroundView.layer.cornerRadius = 6
            
            titleLabel.text = data
            valuesLabel.text = ""
            guard let brain = AppDelegate.shared?.brain else {
                return
            }
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
    
    func dataFor(title: String) {
        guard let brain = AppDelegate.shared?.brain else {
            return
        }
        for i in 0..<brain.allData.count {
            if brain.allData[i].title == title {
                if valuesLabel.text != "" {
                    valuesLabel.text = (valuesLabel.text ?? "") + ", " + (brain.allData[i].value ?? "")
                } else {
                    valuesLabel.text = brain.allData[i].value ?? ""
                }
                
            }
        }
    }
    
    
    
}
