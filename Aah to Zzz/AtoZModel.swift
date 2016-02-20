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
    
    // 3 different data structures to hold the 3 letter word list info, each with its own purpose
    var wordsArray: [String]
    var wordsDictionary: [String: String]
    var wordsSet: Set<String> // may not need to use this outside of this class, consider relocating the declaration
    
    //This prevents others from using the default '()' initializer for this class.
    private init() {
        wordsArray = [String]()
        wordsDictionary = [:] // init empty dictionary
        wordsSet = Set<String>()
        
        var rawWordsArray = [String]()
        rawWordsArray = arrayFromContentsOfFileWithName("3letterwordlist")!
        
        // convert wordsArray to wordsDictionary
        // even elements of wordsArray are the keys (the word itself); odd entries are the values, which are the word definitions
        for var i = 0; i < rawWordsArray.count - 1; i = i + 2 {
            let key = rawWordsArray[i]
            let value = rawWordsArray[i + 1]
            
            wordsArray.append(key)
            wordsDictionary[key] = value
            wordsSet.insert(key)
        }
        // temp. to check it's working
        //generateWordlist()
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
    
    
    //MARK:- Letter and Word functions
    
    
    // wrapper function that calls other functions
    func generateWordlist () -> [String] {
        let letters = generateLetters()
        return getWordlist(letters)
    }
    
    
    func generateLetters () -> [String] {
        
        // create an array of 7 Strings
        // pick 2 random words from wordsArray
        // add each letter to letterSet
        // add another random letter to make 7 letters in set (actually an array)
        
        var letters: [String]
        // Add the first letter to to letterset -- 1st letter is a random letter
        letters = [getRandomLetter()]
        
        let firstWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
        let secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
        
        // Add the 6 letters from 2 random words to the letterset, for a total of 7 letters
        let sixLettersFromWords = wordsArray[firstWordIndex] + wordsArray[secondWordIndex]
        for char in sixLettersFromWords.characters {
            letters.append(String(char))
        }
        
        return letters
    }
    
    func getRandomLetter() -> String {
        let alphabetSoup = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ" // adding extra vowels as they are more freqent in english words
        var alphabetArray: [String] = []
        for char in alphabetSoup.characters {
            alphabetArray.append(String(char))
        }
        return alphabetArray[Int(arc4random_uniform(UInt32(alphabetArray.count)))]
    }
    
    
    
    func getWordlist(letters: [String]) -> [String] {
        
        var allLetterPermutationsSet = Set<String>()
        var sequence: String = ""
        var sequenceCounter: Int = 0
        
        print("letters: \(letters)")
        
        // find all 210 possible permutations of 7 letters into 3 letter sequences, and add to a set
        // (call them 'sequences' as we don't know yet if they are words until they are checked against the 3 letter word list)
        for var i=0; i<letters.count; i++ {
            
            // reset sequence so we start a new word on each loop of i
            sequence = ""
            for var j=0; j<letters.count; j++ {
                if j != i { // a letter can be selected only once per word
                    for var k=0; k<letters.count; k++ {
                        if k != i && k != j {
                            sequence = letters[i] + letters[j] + letters[k]
                            // add the sequence to the set
                            allLetterPermutationsSet.insert(sequence)
                            
                            sequenceCounter++
                            print(sequence)
                        }
                    }
                }
            }
        }
        
        // Find permutations which are also valid words, and sort them alphabetically
        let validWordsSet = allLetterPermutationsSet.intersect(wordsSet)
        let validWordsArray = Array(validWordsSet)

        return validWordsArray.sort()
    }

}


