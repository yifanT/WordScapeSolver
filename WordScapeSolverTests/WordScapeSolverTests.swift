//
//  WordScapeSolverTests.swift
//  WordScapeSolverTests
//
//  Created by Yifan Tang on 2019/4/12.
//  Copyright © 2019 Yifan Tang. All rights reserved.
//

import XCTest
import os.log
@testable import WordScapeSolver

class WordScapeSolverTests: XCTestCase {
    
    //MARK: Word Class Tests
    func testMealInitializationSucceeds() {
        let words = Words(anagramDictionary: nil)!
        saveDictionary(words: words)
        let wordsLoaded = loadDictionary()
        XCTAssertNotNil(words)
        XCTAssertNotNil(wordsLoaded)
    }
    
    private func saveDictionary(words: Words) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: words, requiringSecureCoding: false)
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
