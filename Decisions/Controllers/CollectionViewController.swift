//
//  CollectionViewController.swift
//  Decisions
//
//  Created by Misha Dovhiy on 21.06.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

var selectedCategory = ""
var brain = AppBrain()

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var mainButtons: UIStackView!
    @IBOutlet weak var typeTextfield: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var resultButtons: UIStackView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet var buttonsCollection: [UIButton]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var editingIndex: Int? = nil
    var arr = [""]
    var savePressed = false
    var editPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uodateUI()
    }
    
    func uodateUI() {
        
        brain.loadItems()
        firstLaunch()
        selectedCategory = brain.defaults.value(forKey: "selectedCategory") as? String ?? ""
        getSelectedData()
        collectionView.reloadData()
        showResult(show: false)
        let hideKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(forceHideKeyboard))
        hideKeyboardGesture.direction = .down
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hideKeyboardGesture)
        let titleGesture = UITapGestureRecognizer(target: self, action: #selector(titlePressed))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(titleGesture)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        typeTextfield.delegate = self

        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        for i in 0..<buttonsCollection.count {
            buttonsCollection[i].layer.cornerRadius = 6
            buttonsCollection[i].layer.masksToBounds = true
        }
        
        saveButton.layer.cornerRadius = saveButton.bounds.width / 2
        
        typeTextfield.addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
        savePressed = false
        editPressed = false

    }
    
    func getSelectedData() {

        arr.removeAll()
        for i in 0..<brain.allData.count {
            if brain.allData[i].title == selectedCategory {
                arr.append(brain.allData[i].value ?? "")
            }
        }
        brain.defaults.setValue("\(selectedCategory)", forKey: "selectedCategory")
        print(selectedCategory)
        
        UIView.animate(withDuration: 0.3) {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        UIView.animate(withDuration: 0.6) {
            self.saveButton.alpha = 0
        }
        
        if selectedCategory != "New" {
            titleLabel.text = selectedCategory
            titleLabel.textColor = UIColor.black
            
        } else {
            titleLabel.text = ""
            typeTextfield.becomeFirstResponder()
            titleLabel.textColor = UIColor.lightGray
        }
        
        
        
    }
    
    func showResult(show:Bool, duration: Double = 0.0) {
        
        if show {
            UIView.animate(withDuration: 0.2) {
                self.resultButtons.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                self.resultLabel.alpha = 1
                self.resultLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.titleLabel.alpha = 0
            }
            
            UIView.animate(withDuration: 0.2) {

                self.typeTextfield.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 500, 0)
                self.mainButtons.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -500, 0)
            }
            
            UIView.animate(withDuration: 0.4) {
                self.collectionView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -100, 0)
                self.collectionView.alpha = 0.1
            }
            
        } else {
            UIView.animate(withDuration: duration) {
                self.resultButtons.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 500, 0)
                self.resultLabel.alpha = 0
                self.resultLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                self.titleLabel.alpha = 1
            }
            
            UIView.animate(withDuration: 0.3) {
                
                self.typeTextfield.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                self.mainButtons.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.collectionView.alpha = 1
                self.collectionView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
            

            
        }
    }
    
    @objc func textfieldValueChanged(_ textField: UITextField) {
        
        if titleLabel.text == "" && titleLabel.text != "Save" {
            titleLabel.textColor = UIColor.black
        }
        
        if savePressed == false && editPressed == false {
            if editingIndex != nil {
                arr[editingIndex!] = textField.text ?? ""
                if (textField.text ?? "").count == 0 {
                    arr.remove(at: editingIndex ?? 0)
                    editingIndex = nil
                    performEditing()
                }
                collectionView.reloadData()
            }
            
            if selectedCategory != "New" {
                if editingIndex != nil {
                    performEditing()
                }
            }
        }
        
        if savePressed == true {
            titleLabel.text = textField.text ?? ""
            titleLabel.textColor = UIColor.black
            
            
            if (typeTextfield.text ?? "").count > 1 {
                UIView.animate(withDuration: 0.3) {
                    self.saveButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
                UIView.animate(withDuration: 0.6) {
                    self.saveButton.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.saveButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }
                UIView.animate(withDuration: 0.6) {
                    self.saveButton.alpha = 0
                }
            }
        }
        
        if editPressed == true {
            titleLabel.text = textField.text ?? ""
            
            if (typeTextfield.text ?? "").count < 1 {
                
                if (typeTextfield.text ?? "").count == 0 {
                    titleLabel.text = selectedCategory
                    titleLabel.textColor = UIColor.lightGray
                } else {
                    titleLabel.text = textField.text
                    titleLabel.textColor = UIColor.black
                }
            } else {
                titleLabel.text = textField.text
                titleLabel.textColor = UIColor.black
            }
            
            
        }
    
    }
    
    @objc func titlePressed(_ sender: UITapGestureRecognizer? = nil) {
        
        if selectedCategory != "New" {
            print("edit pressed. \(selectedCategory)")
            editPressed = true
            typeTextfield.text = selectedCategory
            
        }
        
        if selectedCategory == "New" {
            print("Save pressed")
            savePressed = true
            
            if titleLabel.text != "" && titleLabel.text != "Save" {
                typeTextfield.text = titleLabel.text
            }
            
        }
        
        if editingIndex == nil {
            typeTextfield.placeholder = "Enter Category Name"
            typeTextfield.becomeFirstResponder()
        }
        
        if editingIndex != nil {
            editingIndex = nil
        }
        
    }
    
    @objc func forceHideKeyboard(_ sender: UISwipeGestureRecognizer? = nil) {
        
        typeTextfield.endEditing(true)
        editingIndex = nil
        typeTextfield.text = ""
        collectionView.reloadData()
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if keyboardHeight > 1.0 {
                collectionView.contentInset.bottom = keyboardHeight
                let bottomPadding = view.safeAreaInsets.bottom
                print(bottomPadding)
                
                
                UIView.animate(withDuration: 0.3) {
                    self.typeTextfield.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, (keyboardHeight - bottomPadding - 10) * (-1), 0)
                }
                
            }
            
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if editPressed == true {
            if titleLabel.textColor == UIColor.lightGray {
                titleLabel.textColor = UIColor.black
            }
        }
        
        collectionView.contentInset.bottom = 10
        UIView.animate(withDuration: 0.3) {
            self.typeTextfield.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        }
        editingIndex = nil
        if editPressed == true {
            performEditing()
            editPressed = false
        }
        if savePressed == true {
            performSaving(saveButton)
            savePressed = false
        }
        
        if editPressed == false && arr.count > 1 {
            if titleLabel.text == "" {
                titleLabel.text = "Save"
                titleLabel.textColor = UIColor.lightGray
            }
        }
        
    }
    
    @IBAction func categoriesPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "toCategories", sender: self)
        
    }
    
    @IBAction func shakePressed(_ sender: UIButton) {

        if arr.count > 1 {
            typeTextfield.endEditing(true)
            resultLabel.text = arr.randomElement() ?? "enuble"
            showResult(show: true, duration: 0.3)
        }
        
    }
    
    @IBAction func closeResultPressed(_ sender: UIButton) {
        
        resultLabel.text = ""
        showResult(show: false, duration: 0.3)
    }
    
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {

                self.getSelectedData()
                brain.loadItems()
                self.collectionView.reloadData()

            }
        }
    }
    
    @IBAction func performSaving(_ sender: UIButton) {
        
        if (arr.count > 1) && (titleLabel.text != "" && titleLabel.text != " " && titleLabel.text != "Save" && titleLabel.text != "New") {
            savePressed = false
            selectedCategory = titleLabel.text ?? ""
            typeTextfield.text = ""
            typeTextfield.placeholder = "Type something"
            
            for i in 0..<arr.count {
                let new = Values(context: brain.context)
                new.title = selectedCategory
                new.value = arr[i]
                brain.saveItems()
            }
            brain.loadItems()
            brain.defaults.setValue("\(selectedCategory)", forKey: "selectedCategory")
            brain.showError(text: "performSaving \(selectedCategory)")
            UIView.animate(withDuration: 0.3) {
                self.saveButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }
            UIView.animate(withDuration: 0.6) {
                self.saveButton.alpha = 0
            }
        } else {
            brain.showError(text: "cant save")
        }
        
    }
    
    func performEditing() {
        
        if titleLabel.text != "" && arr.count > 1 {
            if editPressed == true {
                editPressed = false
                typeTextfield.endEditing(true)
                typeTextfield.text = ""
                typeTextfield.placeholder = "Type something"
            }
            
            brain.deleteData(with: selectedCategory)
            selectedCategory = titleLabel.text ?? ""
            
            for i in 0..<arr.count {
                let new = Values(context: brain.context)
                new.title = selectedCategory
                new.value = arr[i]
                brain.saveItems()
            }
            brain.loadItems()
            brain.defaults.setValue("\(selectedCategory)", forKey: "selectedCategory")
            brain.showError(text: "performEditing")
            saveButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            saveButton.alpha = 0
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if arr.count > 1 && selectedCategory == "" {
            selectedCategory = "Uncategorized"
            performSaving(saveButton)
        }
        
        editingIndex = nil
        if editPressed == true {
            performEditing()
            editPressed = false
        }
        if savePressed == true {
            performSaving(saveButton)
            savePressed = false
        }
    }
    
    func firstLaunch() {
        
        if !brain.defaults.bool(forKey: "First Launch") {
            print("first")
            brain.createDefaultCategories()
            brain.loadItems()
            selectedCategory = brain.allData[0].title ?? ""
            getSelectedData()
            print(selectedCategory)
            print(brain.allData.count, "alldata")
            brain.defaults.setValue(true, forKey: "First Launch")
            collectionView.reloadData()
        }
    }
    
    func addToCollection(_ textField: UITextField) {
        if textField.text != "" {
            arr.append(textField.text ?? "")
            collectionView.reloadData()
            typeTextfield.text = ""
            
            if selectedCategory != "New" {
                performEditing()
            }
            
            if arr.count > 1 {
                if selectedCategory == "New" {
                    titleLabel.text = "Save"
                    titleLabel.textColor = UIColor.lightGray
                    
                } else {
                    titleLabel.textColor = UIColor.black
                    
                }
            }
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: self.arr.count - 1, section: 0), at: .top, animated: true)
            }
            
        }
    }
    
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        
        cell.setupCell(cell)
        if arr.count > 0 {
            cell.titleLabel.text = arr[indexPath.row]
        }
        cell.contentView.backgroundColor = indexPath.row == editingIndex ? UIColor.red : UIColor.green
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if resultLabel.text == "" {
            editingIndex = indexPath.row
            typeTextfield.text = arr[indexPath.row]
            typeTextfield.becomeFirstResponder()
            collectionView.reloadData()
            print(editingIndex!)
            savePressed = false
            editPressed = false
        }
        
    }
    
    
}

extension CollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if savePressed == false && editPressed == false {
            if editingIndex == nil {
                addToCollection(textField)
            }
            
            if editingIndex != nil {
                editingIndex = nil
                textField.text = ""
                textField.endEditing(true)
                collectionView.reloadData()
            }
        }
        
        if savePressed == true {
            performSaving(saveButton)
        }
        
        if editPressed == true {
            performEditing()
        }
        
        return true
    }
    
}

class CollectionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    func setupCell(_ cell: UICollectionViewCell) {
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 12
        cell.isUserInteractionEnabled = true
    }
    
}

