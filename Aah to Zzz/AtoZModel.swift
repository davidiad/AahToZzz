//
//  AtoZmodel.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation

class AtoZModel {
    
    static let sharedInstance = AtoZModel() // defines as singleton
    
    var wordsArray: [String]
    var wordsDictionary: [String: String]
    
    //This prevents others from using the default '()' initializer for this class.
    private init() {
        wordsArray = [String]()
        wordsDictionary = [:] // init empty dictionary
        
        var rawWordsArray = [String]()
        rawWordsArray = arrayFromContentsOfFileWithName("3letterwordlist")!
        
        // convert wordsArray to wordsDictionary
        // even elements of wordsArray are the keys (the word itself); odd entries are the values, which are the word definitions
        for var index = 0; index < rawWordsArray.count - 1; index = index + 2 {
            let key = rawWordsArray[index]
            let value = rawWordsArray[index + 1]
            
            wordsArray.append(key)
            wordsDictionary[key] = value
        }
    }
    
    // read in the 3 letter word list with word definitions
    func arrayFromContentsOfFileWithName(fileName: String) -> [String]? {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt") else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            return content.componentsSeparatedByString("\n")
        } catch _ as NSError {
            return nil
        }
    }
    
    func generateLetterSet () -> [String] {
        
        // create an array of 7 Strings
        // pick 2 random words from wordsArray
        // add each letter to letterSet
        // add another random letter to make 7 letters in set (actually an array)
        
        var letterSet: [String]
        letterSet = [getRandomLetter()] // Add 1 random letter to the letterSet
        
        let firstWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
        let secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
        
        // Add the 6 letters from 2 random words to the letterset, for a total of 7 letters
        let sixLettersFromWords = wordsArray[firstWordIndex] + wordsArray[secondWordIndex]
        for char in sixLettersFromWords.characters {
            letterSet.append(String(char))
        }
        
        return letterSet
    }
    
    func getRandomLetter() -> String {
        let alphabetSoup = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ" // adding extra vowels as they are more freqent in english words
        var alphabetArray: [String] = []
        for char in alphabetSoup.characters {
            alphabetArray.append(String(char))
        }
        return alphabetArray[Int(arc4random_uniform(UInt32(alphabetArray.count)))]
    }

}


