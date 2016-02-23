//
//  AtoZmodel.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData

class AtoZModel {
    
    static let sharedInstance = AtoZModel() // defines as singleton
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // constant of what mix of characters to choose random letters from
    // adding extra vowels as they are more freqent in english words
    let alphabetSoup = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
    
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
        saveGame() // create a GameData object, the root object for data persistence
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
    
    // getting a wordlist from letters that can be called from another class
    func generateWordlist (letters: [Letter]) -> [String] {
        return getWordlist(letters)
    }
    
    //TODO: change to an array of managed object Letter's
    func generateLetters () -> [Letter] {
        
        // create an array that will be filled with 7 Strings
        // TODO: can this array be replaced by the LetterSet?
        var letters: [Letter]
        // Add the first letter to to letterset -- 1st letter is a random letter
        letters = [createLetter(nil)]
        
        // pick 2 random words from wordsArray
        let firstWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
        let secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
        
        // Add the 6 letters from 2 random words to the letterset, for a total of 7 letters
        let sixLettersFromWords = wordsArray[firstWordIndex] + wordsArray[secondWordIndex]
        for char in sixLettersFromWords.characters {
            letters.append(createLetter(String(char)))
        }
        
        // create a LetterSet managed object
        let letterset = NSEntityDescription.insertNewObjectForEntityForName("LetterSet", inManagedObjectContext: sharedContext) as! LetterSet
        // TODO:-add the LetterSet to the GameData object
        // make the LetterSet the letterset property for each Letter
        for letter in letters {
            letter.letterset = letterset
        }
        // TODO:Make a struct for LetterPositions. Add as a property to Letter.


        
        // save the managed object context
        saveContext()
        
        return letters
    }
    
    
    // creates a Letter object from a passed-in String, or generates a random 1 letter string if nil is passed in
    func createLetter(var letterString: String?) -> Letter {
        //TODO: test for validity of letter (e.g. what if it's a number, or more than 1 letter)
        let alphabetArray = generateAlphabetArray()
        if letterString == nil {
            letterString = alphabetArray[Int(arc4random_uniform(UInt32(alphabetArray.count)))]
        }
        let letter = Letter(someLetter: letterString!, context: sharedContext)
        //let letter = NSEntityDescription.insertNewObjectForEntityForName("Letter", inManagedObjectContext: sharedContext) as! Letter
        return letter
    }
    
    // generate the Alphabet array just once, and store as a constant
    // TODO: There must be a way to have this array created only once, not every time a random letter is generated. Compute it in a Struct, and then get the array from the Struct?
    func generateAlphabetArray() -> [String] {
        var alphabetArray: [String] = []
        for char in alphabetSoup.characters {
            alphabetArray.append(String(char))
        }
        return alphabetArray
    }
    
    
    func getWordlist(letters: [Letter]) -> [String] {
        
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
                            sequence = letters[i].letter! + letters[j].letter! + letters[k].letter!
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
    
    //MARK:- Save Managed Object Context helper
    func saveContext() {
        dispatch_async(dispatch_get_main_queue()) {
            _ = try? self.sharedContext.save()
        }
    }
    
    //MARK:- GameData funcs
    
    func saveGame() {
       // _ = makeMapDictionary()
        deleteGames() // delete all games (for now) so there is only one at a time
        _ = NSFetchRequest(entityName: "MapViewInfo")
        
        
        let game = NSEntityDescription.insertNewObjectForEntityForName("GameData", inManagedObjectContext: sharedContext) as! GameData
        
        game.name = "David's first game"
//        mapInfo.lat = NSNumber(double: map.centerCoordinate.latitude)
//        mapInfo.lon = NSNumber(double: map.centerCoordinate.longitude)
//        mapInfo.latDelta = NSNumber(double: map.region.span.latitudeDelta)
//        mapInfo.lonDelta = NSNumber(double: map.region.span.longitudeDelta)
        
        saveContext()
    }
    
    func deleteGames() {
        let fetchRequest = NSFetchRequest(entityName: "GameData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try sharedContext.executeRequest(deleteRequest)
        } catch let error as NSError {
            print("Error in deleteMapInfo: \(error)")
        }
    }
    
//    // make dict for Game Data values
//    func makeGameDataDictionary() -> [String : AnyObject] {
//        
//        let mapDictionary = [
//            "lat": NSNumber(double: map.centerCoordinate.latitude),
//            "lon": NSNumber(double: map.centerCoordinate.longitude),
//            "latDelta": NSNumber(double: map.region.span.latitudeDelta),
//            "lonDelta": NSNumber(double: map.region.span.longitudeDelta),
//            "zoom": NSNumber(double: 1.0)
//        ]
//        
//        return mapDictionary
//    }

}


