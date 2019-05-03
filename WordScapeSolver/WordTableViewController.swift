//
//  WordTableViewController.swift
//  WordScapeSolver
//
//  Created by 汤逸凡 on 2019/5/1.
//  Copyright © 2019 汤逸凡. All rights reserved.
//

import UIKit
import os.log

class WordTableViewController: UITableViewController {
    
    //MARK: Properties
    var words = [Words]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedWords = loadWords() {
            words += savedWords
        } else {
            loadSampleWords()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WordTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WordTableViewCell else {
            fatalError("Something wrong")
        }
        let word = words[indexPath.row]
        cell.nameLabel.text = word.name
        cell.photoImageView.image = word.photo
        cell.ratingControl.rating = word.rating
        return cell
    }

    //MARK: Actions
    @IBAction func unwindToWordList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? WordViewController, let word = sourceViewController.word {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                words[selectedIndexPath.row] = word
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new word.
                let newIndexPath = IndexPath(row: words.count, section: 0)
                words.append(word)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveWords()
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            words.remove(at: indexPath.row)
            saveWords()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let wordDetailViewController = segue.destination as? WordViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? WordTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedWord = words[indexPath.row]
            wordDetailViewController.word = selectedWord
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }
    
    //MARK: Private Methods
    
    private func loadSampleWords() {
        for index in 1..<4 {
            let photo = UIImage(named: "DefaultPhoto")
            guard let word = Words(name: "Happy", photo: photo, rating: index) else {
                fatalError("Unable to instantiate word")
            }
            words.append(word);
        }
    }
    
    private func saveWords() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: words, requiringSecureCoding: false)
            try data.write(to: Words.ArchiveURL)
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }

    private func loadWords() -> [Words]? {
        let fullPath = Words.ArchiveURL
        if let nsData = NSData(contentsOf: fullPath) {
            do {
                let data = Data(referencing:nsData)
                if let loadedMeals = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Words] {
                    return loadedMeals
                }
            } catch {
                print("Couldn't read file.")
                return nil
            }
        }
        return nil
    }
}
