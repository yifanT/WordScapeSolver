//
//  Words.swift
//  WordScapeSolver
//
//  Created by Yifan Tang on 2019/4/30.
//  Copyright © 2019 Yifan Tang. All rights reserved.
//

import UIKit
import os.log

class Words: NSObject, NSCoding {
    
    //MARK: Properties
    var dictionary: [String]?
    var anagramDictionary: [String: [String]]?
    
    init?(anagramDictionary: [String: [String]]?) {
        super.init()
        if anagramDictionary != nil {
            self.anagramDictionary = anagramDictionary
        } else {
            // read dictionary from file
            let path = Bundle.main.path(forResource: "popular", ofType: "txt")!
            do {
                let file = try String(contentsOfFile: path)
                self.dictionary = file.components(separatedBy: "\n")
                constructAnagramDictionary()
            } catch {
                os_log("Fatal Error: Couldn't read the contents!", log: OSLog.default, type: .debug)
                return nil
            }
        }
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("wordsDictionary")
    
    //MARK: Types
    struct PropertyKey {
        static let anagramDictionary = "anagramDictionary"
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(anagramDictionary, forKey: PropertyKey.anagramDictionary)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let anagramDictionary = aDecoder.decodeObject(forKey: PropertyKey.anagramDictionary) as? [String: [String]]
        self.init(anagramDictionary: anagramDictionary)
    }
    
    //MARK: Public Methods
    func getAnagram(word: String) -> [String]? {
        let sortedWord = String(word.sorted())
        return anagramDictionary?[sortedWord]
    }
    
    //MARK: Private Methods
    private func constructAnagramDictionary() {
        let dict = dictionary!
        anagramDictionary = [:]
        for i in 0..<dict.count {
            let sortedWord = String(dict[i].sorted())
            if (anagramDictionary![sortedWord] == nil) {
                anagramDictionary![sortedWord] = [dict[i]]
            } else {
                var arr = anagramDictionary![sortedWord]!
                arr.append(dict[i])
                anagramDictionary![sortedWord] = arr
            }
        }
    }
}
