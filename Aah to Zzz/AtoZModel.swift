//
//  AtoZmodel.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
    
    var game: GameData? // The managed object that is at the root of the object graph
    var positions: [Position]? // array to hold the letter Positions. Needed??
    
    //MARK:- vars for background gradient
    var location1: CGFloat?
    var location2: CGFloat?
    var location3: CGFloat?
    var location4: CGFloat?
    //MARK:-
    
    //This prevents others from using the default '()' initializer for this class.
    private init() {

        positions = [Position]()
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
        game = fetchGameData() // fetches the exisiting game if there is one, or else creates a new game
        
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
    
    // Instead of returning an array of strings, return an array of Word objects
    // Called from the IBAction New List button as sender
    func generateWords (letters: [Letter]) -> [Word] {
        let wordlist = generateWordlist(letters)
        let wordManagedObjectsArray = createOrUpdateWords(wordlist)
        return wordManagedObjectsArray
        // once Words are in the context, the fetchedResultsController retrieves them
        // so might not need to return anything from this func, really.
    }
    
    
    // wrapper function that calls other functions
    func generateWordlist () -> [String] {
        let letters = generateLetters()
        return getWordlist(letters)
    }
    
    // getting a wordlist from letters that can be called from another class
    func generateWordlist (letters: [Letter]) -> [String] {
        return getWordlist(letters)
    }
    
    func generateLetters () -> [Letter] {
        
        // create an array that will be filled with 7 Strings
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
        // add the LetterSet to the GameData object
        letterset.game = game
        saveContext()
        letterset.letterSetID = String(letterset.objectID.URIRepresentation())
        
        game?.currentLetterSetID = letterset.letterSetID
        
        // make the LetterSet the letterset property for each Letter
        for letter in letters {
            letter.letterset = letterset
        }

        // save the managed object context
        saveContext()
        
        return letters
    }
    
    // a variation of generateLetters, this one returns the actual LetterSet managed object that can be stored
    // Can this replace generateLetters?//TODO: find out
    func generateLetterSet () -> LetterSet {
        
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
        // add the LetterSet to the GameData object
        letterset.game = game
        saveContext()
        letterset.letterSetID = String(letterset.objectID.URIRepresentation())
        
        game?.currentLetterSetID = letterset.letterSetID
        // this should do the same as above, and much simpler
        // TODO: consider replacing the ID way of finding letterset
        game?.currentLetterSet = letterset
        
        // make the LetterSet the letterset property for each Letter
        // and set the index for each letter for id'ing it later
        for var i=0; i<letters.count; i++ {
            letters[i].letterset = letterset
            letters[i].index = Int16(i)
            // After the positions have been created...
            letters[i].position = positions![i]
            positions![i].letter = letters[i]
        }
        
        // save the managed object context
        saveContext()

        return letterset
    }
    
    func generateLetterPosition(tileNum: Int) -> CGPoint {
        var xpos: CGFloat
        var ypos: CGFloat
        switch tileNum {
         
        // counting from the bottom to the top
        case 0, 1, 2:
            xpos = CGFloat(tileNum) * 65.0
            ypos = 600.0
        case 3, 4, 5:
            xpos = (CGFloat(tileNum - 3) * 85.0) - 40.0
            ypos = 500.0
        case 6:
            xpos = 130.0
            ypos = 400.0
        case 7, 8, 9:
            xpos = 45.0 + CGFloat(tileNum - 7) * 55.0
            ypos = 260.0
        default:
            xpos = 130.0
            ypos = 400.0
        }
        
        return CGPointMake(xpos, ypos)
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
    
    //MARK:- Word functions
    
    //TODO: rename all the word funcs  so less confusing and more clear
    func getWordlist(letters: [Letter]) -> [String] {
        
        var allLetterPermutationsSet = Set<String>()
        var sequence: String = ""
        
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
    
    // either fetch or create Word managed objects for the current list, and update values to reflect their status
    func createOrUpdateWords(wordlist: [String]) -> [Word] {
        var currentWords = [Word]()
        // can I assume that a GameData has been created, and etc?
        // starting a new fetch request, in case none has been made, or it needs updating
        var newWord: Word
        //TODO:- keep the words sorted
        for var i=0; i<wordlist.count; i++ {
       // for wordString in wordlist {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            // Create Predicate
            let predicate = NSPredicate(format: "%K == %@", "word", wordlist[i])
            fetchRequest.predicate = predicate
            
            do {
                let wordsArray = try sharedContext.executeFetchRequest(fetchRequest) as! [Word]
                // check to see if anything was returned
                if wordsArray.count > 0 {
                    // a Word was returned for that String. Do not create another with the same string!
                    newWord = wordsArray[0]
                } else {
                    newWord = Word(wordString: wordlist[i], context: sharedContext)
                    newWord.found = false
                }
                
                // Whether newly created, or fetched from existing, do the following:
                // assign letterset to the string
                // set inCurrentList to true
                // set found to false
                // add 1 to numTimesPlayed
                // set the game property
                newWord.game = game // make sure that game is not nil
                // need to find the current letterset
                newWord.letterlist = game?.currentLetterSet as? LetterSet //TODO: need to use ID to locate letterset?
                newWord.inCurrentList = true
                
                newWord.numTimesPlayed += 1
                currentWords.append(newWord)
//                print("newWord.word: \(newWord.word)")
//                print("newWord.found: \(newWord.found)")
//                print("newWord.inCurrentList: \(newWord.inCurrentList)")
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
        }
        
        saveContext()
        return currentWords
 
    }
    
    func getDefinition(word: String) -> String {
        if let definition = wordsDictionary[word] {
            return definition
        }
        
        return ("No definition was found for \(word)")
    }
    
    //MARK:- GameData funcs
    
    // Fetch the existing game from the store, or create one if there is none
    func fetchGameData() -> GameData {
        let fetchRequest = NSFetchRequest(entityName: "GameData")
        do {
            let gameArray = try sharedContext.executeFetchRequest(fetchRequest) as! [GameData]
            if gameArray.count > 0 {
                for var i=0; i<10; i++ {
                    positions = gameArray[0].positions?.allObjects as? [Position]
                    positions!.sortInPlace {
                        ($0.index as Int16?) < ($1.index as Int16?)
                    }
                }
                return gameArray[0]
            } else {
                let gameData = makeGameDataDictionary()
                let newGame = GameData(dictionary: gameData, context: sharedContext)
                // create the Positions and add to game
                for var i=0; i<10; i++ {
                    // create the Positions for the tiles. There are 10 per game.
                    // TODO: use init instead
                    let position = NSEntityDescription.insertNewObjectForEntityForName("Position", inManagedObjectContext: sharedContext) as! Position
                    position.index = Int16(i)
                    position.game = newGame
                    let pos = generateLetterPosition(i)
                    position.xPos = Float(pos.x)
                    position.yPos = Float(pos.y)
                    positions?.append(position)
                    
                }
                saveContext()
                return newGame
            }
        // in the case there is a fetch error, also create a new game object
        } catch let error as NSError {
            print("Error in fetchGameData(): \(error)")
            //TODO: can the catch itself generate an error?
            //do we need to return GameDatare?
            let defaultInfo = makeGameDataDictionary()
            return GameData(dictionary: defaultInfo, context: sharedContext)
        }
    }
    
    func createPositions(game: GameData) {
        
    }
    
    func createGame() {
        deleteGames() // delete all games (for now) so there is only one at a time
        _ = NSFetchRequest(entityName: "GameData")
        
        
        let game = NSEntityDescription.insertNewObjectForEntityForName("GameData", inManagedObjectContext: sharedContext) as! GameData
        
        game.name = "David's first game"
        
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
    
    // make dict for Game Data values
    func makeGameDataDictionary() -> [String : AnyObject] {
        
        let gameDataDictionary = [
            "name": "David Game 1"
        ]
        
        return gameDataDictionary
    }
    
    //MARK:- Save Managed Object Context helper
    func saveContext() {
        if sharedContext.hasChanges {
            do {
                try sharedContext.save()
            } catch {
                let nserror = error as NSError
                print("Could not save the Managed Object Context")
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK:- Gradient background funcs
    func yellowPinkBlueGreenGradient() -> CAGradientLayer {
        
        let colorOne = UIColor(hue: 0.25, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef // green
        let colorTwo = UIColor(hue: 0.597, saturation: 0.75, brightness: 1.00, alpha: 1).CGColor as CGColorRef // blue
        let colorThree = UIColor(hue: 0.833, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef //magenta
        let colorFour = UIColor(hue: 0.164, saturation: 1.0, brightness: 1.0, alpha: 1).CGColor as CGColorRef //dark blue
        
        let gradientColors: Array <AnyObject> = [colorOne, colorTwo, colorThree, colorFour]
        
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0, 0.2, 0.58, 0.97]
        
        return gradientLayer
    }

}


