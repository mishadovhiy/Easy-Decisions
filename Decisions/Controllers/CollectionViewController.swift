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
let colors = Colors()

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
    @IBOutlet weak var shakeButton: UIButton!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
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
        
        saveButton.layer.cornerRadius = 6
        typeTextfield.addTarget(self, action: #selector(textfieldValueChanged), for: .editingChanged)
        savePressed = false
        editPressed = false
        
        messageView.layer.masksToBounds = true
        messageView.layer.cornerRadius = 6
        messageView.backgroundColor = colors.lightYellow
        
        let hideMessageGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideMessageSwipped))
        hideMessageGesture.direction = .up
        messageView.isUserInteractionEnabled = true
        messageView.addGestureRecognizer(hideMessageGesture)

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
            titleLabel.textColor = colors.title
            
        } else {
            titleLabel.text = ""
            typeTextfield.becomeFirstResponder()
            titleLabel.textColor = colors.gray
        }
        
        toggleShakeButton()
        typeTextfield.text = ""
        typeTextfield.placeholder = "Type something"
        messageView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -250, 0)
        
    }
    
    func toggleShakeButton(duration: TimeInterval = 4.0) {
        if arr.count > 1 {
            UIView.animate(withDuration: 0.4) {
                self.shakeButton.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
        } else {
            UIView.animate(withDuration: 0.6) {
                self.shakeButton.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -200, 0)
            }
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
            titleLabel.textColor = colors.title
        }
        
        if savePressed == false && editPressed == false {
            if editingIndex != nil {
                arr[editingIndex!] = textField.text ?? ""
                if (textField.text ?? "").count == 0 {
                    arr.remove(at: editingIndex ?? 0)
                    toggleShakeButton()
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
            titleLabel.textColor = colors.title
            
            
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
                    titleLabel.textColor = colors.gray
                } else {
                    titleLabel.text = textField.text
                    titleLabel.textColor = colors.title
                }
            } else {
                titleLabel.text = textField.text
                titleLabel.textColor = colors.title
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
    
    @objc func hideMessageSwipped(_ sender: UISwipeGestureRecognizer? = nil) {
        
        UIView.animate(withDuration: 0.6) {
            self.messageView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -250, 0)
        }
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
        
        typeTextfield.placeholder = "Type something"
        if editPressed == true {
            if titleLabel.textColor == colors.gray {
                titleLabel.textColor = colors.title
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
                titleLabel.textColor = colors.gray
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
            showMessage(with: "\(selectedCategory) Saved!")
            
            UIView.animate(withDuration: 0.3) {
                self.saveButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }
            UIView.animate(withDuration: 0.6) {
                self.saveButton.alpha = 0
            }
        } else {
            if arr.count < 1 {
                UIImpactFeedbackGenerator().impactOccurred()
                showMessage(with: "Can't save as \(titleLabel.text ?? "")", color: colors.error ?? UIColor.red)
            }
        }
        
    }
    
    func performEditing() {
        
        //if titleLabel.text != "" && arr.count > 1 {
        if (arr.count > 1) && (titleLabel.text != "" && titleLabel.text != " " && titleLabel.text != "Save" && titleLabel.text != "New") {
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
            print("edited")
            saveButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            saveButton.alpha = 0
        } else {
            UIImpactFeedbackGenerator().impactOccurred()
            showMessage(with: "Can't save changes for \(titleLabel.text ?? "")", color: colors.error ?? UIColor.red)
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
            toggleShakeButton()
            
            if selectedCategory != "New" {
                performEditing()
            }
            
            if arr.count > 1 {
                if selectedCategory == "New" {
                    titleLabel.text = "Save"
                    titleLabel.textColor = colors.gray
                    
                } else {
                    titleLabel.textColor = colors.title
                    
                }
            }
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: self.arr.count - 1, section: 0), at: .top, animated: true)
            }
            
        }
    }
    
    func showMessage(with text: String, color: UIColor = colors.success ?? UIColor.white) {
        
        messageView.backgroundColor = colors.success
        messageLabel.text = text
        UIView.animate(withDuration: 0.6) {
            self.messageView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
           
        }
        
        UIView.animate(withDuration: 0.9) {
            self.messageView.backgroundColor = color
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (action) in
            UIView.animate(withDuration: 0.6) {
                self.messageView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -250, 0)
                self.messageView.backgroundColor = colors.success
                self.messageLabel.text = ""
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
        cell.contentView.backgroundColor = indexPath.row == editingIndex ? colors.orange : colors.yellow
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

