//
//  SearchWordViewController.swift
//  WordScapeSolver
//
//  Created by Yifan Tang on 2019/5/3.
//  Copyright © 2019 Yifan Tang. All rights reserved.
//

import UIKit
import os.log

class SearchWordViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: Properties
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var wordTextView: UITextView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var numberPicker: UIPickerView!
    
    var anagaramDict: Words?
    var wordLenMin = 3
    var wordLenMax = 3
    let pickerData = ["3", "4", "5", "6", "7", "8", "9", "10", ">10", "Any"]
    
    //MARK: Actions
    @IBAction func search(_ sender: UIButton) {
        wordTextView.text = ""
        let wordArr = allSubsets(word: String(wordTextField.text!.sorted()), maxLen: wordLenMax, minLen: wordLenMin)
        for word in wordArr {
            guard let words = anagaramDict?.getAnagram(word: word) else {
                continue
            }
            for i in 0..<words.count {
                wordTextView.text = wordTextView.text + words[i] + " "
            }
        }
        if wordTextView.text == "" {
            wordTextView.text = "No Results!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordTextField.delegate = self
        
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        wordTextView.isScrollEnabled = true
        wordTextView.textAlignment = .left
        wordTextView.font = UIFont.systemFont(ofSize: 20.0)
        
        if let savedDict = loadDictionary() {
            anagaramDict = savedDict
        }
        else {
            anagaramDict = Words(anagramDictionary: nil)
            saveDictionary()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        searchButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSearchButtonState()
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < 8 {
            wordLenMax = Int(pickerData[row])!
            wordLenMin = Int(pickerData[row])!
        }
        else if row == 8 {
            wordLenMin = 11
            wordLenMax = 30
        }
        else {
            wordLenMin = 3
            wordLenMax = 30
        }
    }
    
    //MARK: Private Methods
    private func updateSearchButtonState() {
        // Disable the Save button if the text field is empty.
        let text = wordTextField.text ?? ""
        searchButton.isEnabled = !text.isEmpty
    }
    
    private func allSubsets(word: String, maxLen: Int, minLen: Int) -> [String] {
        var frequencies: [Character: Int]
        let baseCounts = zip(word, repeatElement(1, count: Int.max))
        frequencies = Dictionary(baseCounts, uniquingKeysWith: +)
        var allCombos = [""]
        var resCombos: [String] = [String]()
        for (key, value) in frequencies {
            var cur = [""]
            for _ in 0..<value {
                cur.append(cur.last! + String(key))
            }
            cur.removeFirst()
            for combo in allCombos {
                for c in cur {
                    let tmp = combo + c
                    allCombos.append(tmp)
                    if tmp.count >= wordLenMin && tmp.count <= wordLenMax {
                        resCombos.append(tmp)
                    }
                }
            }
        }
        return resCombos
    }
    
    private func saveDictionary() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: anagaramDict!, requiringSecureCoding: false)
            try data.write(to: Words.ArchiveURL)
            os_log("Dictionary successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save dictionary...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadDictionary() -> Words? {
        let fullPath = Words.ArchiveURL
        if let nsData = NSData(contentsOf: fullPath) {
            do {
                let data = Data(referencing:nsData)
                if let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Words {
                    return dict
                }
            } catch {
                return nil
            }
        }
        return nil
    }
}
