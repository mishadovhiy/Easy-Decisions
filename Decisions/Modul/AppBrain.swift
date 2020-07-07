//
//  AppData.swift
//  Decisions
//
//  Created by Misha Dovhiy on 01.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

struct AppBrain {
    
    let defaults = UserDefaults.standard
    
    var allData = [Values]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createDefaultCategories() {
        
        let dicktionary = [
            ValuesStract(title: "Movies", values: ["one", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two", "two"]),
            ValuesStract(title: "Other", values: ["Three", "Four"]),
            ValuesStract(title: "true Or False", values: ["True", "False"])
        ]
        
        for k in 0..<dicktionary.count {
            for i in 0..<dicktionary[k].values.count {
                let new = Values(context: context)
                new.title = dicktionary[k].title
                new.value = dicktionary[k].values[i]
                saveItems()
            }
        }
        
    }
    
    mutating func deleteData(with title: String) {

        for i in 0..<allData.count {
            if allData[i].title == title {
                context.delete(allData[i])
            }
        }
        saveItems()
        loadItems()
    }
    
    mutating func loadItems(_ request: NSFetchRequest<Values> = Values.fetchRequest(), predicate: NSPredicate? = nil) {
        
        do { allData = try context.fetch(request)
        } catch { print("\n\nERROR FETCHING DATA FROM CONTEXTE\n\n", error)}

    }
    
    func saveItems() {
        
        do { try context.save()
        } catch { print("\n\nERROR ENCODING CONTEXT\n\n", error) }
    }
    
    func showError(text: String, color: UIColor = UIColor.red) {
        print(text)
    }
    
}


struct ValuesStract {
    let title: String
    let values: [String]
}
