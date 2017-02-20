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
import GameplayKit // used for random shuffling methods

class AtoZModel {
    
    static let sharedInstance = AtoZModel() // defines as singleton
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // constant of what mix of characters to choose random letters from
    // adding extra vowels as they are more freqent in english words
    let alphabetSoup = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ" // will come from gameInfo
    
    var dictionaryName: String // which dictionary 3 letter word list to use
    // 3 different data structures to hold the 3 letter word list info, each with its own purpose
    var wordsArray: [String]
    var wordsDictionary: [String: String]
    var wordsSet: Set<String> // may not need to use this outside of this class, consider relocating the declaration
    // update: using wordsSet in ProgressViewController
    var inactiveCount: Int?
    
    var game: Game? // The managed object that is at the root of the object graph
    var gameTypeInfo: GameTypeInfo? // holds the game info that is dependent on the gameType
    var positions: [Position]? // array to hold the letter Positions. Needed??
    
    var anchorPoint: CGPoint? // anchor point to calculate tile and UI position. Will depend on device size. And will be adjustable by the user to some degree to what works best (hand size, left or right handed, personal preference.
    
    //MARK:- vars for background gradient
    var location1: CGFloat?
    var location2: CGFloat?
    var location3: CGFloat?
    var location4: CGFloat?
    //MARK:-
    
    //This prevents others from using the default '()' initializer for this class.
    private init() {
        //TODO: check the new words from OSPD5 that are in question
        positions = [Position]()
        wordsArray = [String]()
        wordsDictionary = [:] // init empty dictionary
        wordsSet = Set<String>()
        
        dictionaryName = "OSPD5_3letter" // default wordlist
        
        var rawWordsArray = [String]()
        rawWordsArray = arrayFromContentsOfFileWithName(dictionaryName)!
        
        // convert wordsArray to wordsDictionary
        // even elements of wordsArray are the keys (the word itself); odd entries are the values, which are the word definitions
        //for var i = 0; i < rawWordsArray.count - 1; i = i + 2 { // Swift2 code
        for i in 0.stride(to: rawWordsArray.count - 1, by: 2) { // Swift3 code
            let key = rawWordsArray[i]
            let value = rawWordsArray[i + 1]
            
            wordsArray.append(key)
            wordsDictionary[key] = value
            wordsSet.insert(key)
        }
        game = fetchGame() // fetches the exisiting game if there is one, or else creates a new game
        
        // gameTypeSetting maps enum to int(for saving in Core Data, encapsulated in GameType
        gameTypeInfo = GameTypeInfo(gameType: game!.gameTypeSet)
        
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
    
    // May not be used. using generateLetterSet instead
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
        
        game?.data?.currentLetterSetID = letterset.letterSetID
        
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
        
        
        /************ ??never used??
        var firstWordIndex: Int
        var secondWordIndex: Int
        ********/
        
        //TODO:- pick the words only from unmastered words
        // Case 1: No Words have been saved -- no changes to code
        // Case 2: Some, but not all, Words have been saved. 
        // Need to choose only from the unsaved in cases 1 and 2
        // Case 2.5: All but 1 word have been saved
        // Case 3: All Words have been saved, and at least 2 are unmastered
        // Case 4: All Words have been saved, and 1 is unmastered
        // Case 5: All Words have been saved, and none are unmastered
        
//        let fetchRequest = NSFetchRequest(entityName: "Word")
//        
//        do {
//            let fetchedWords = try sharedContext.executeFetchRequest(fetchRequest) as! [Word]
//            // check to see if anything was returned
//            let numUnsavedWords = wordsArray.count - fetchedWords.count
//            switch fetchedWords.count {
//            case 0:
//                // need to pick from unmastered words
//                // pick 2 random words from wordsArray
//                firstWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
//                secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
//            case 1:
//                print("Need to find that one unsaved word")
//            default:
//                print("Need to find unmastered words")
//                
//            }
//        } catch {
//            let fetchError = error as NSError
//            print(fetchError)
//        }


        
        // Add the 6 letters from 2 random words to the letterset, for a total of 7 letters
        //let sixLettersFromWords = wordsArray[firstWordIndex] + wordsArray[secondWordIndex]
        let sixLettersFromWords = getWordsForLetters()
        for char in sixLettersFromWords.characters {
            letters.append(createLetter(String(char)))
        }
        
        // create a LetterSet managed object
        let letterset = NSEntityDescription.insertNewObjectForEntityForName("LetterSet", inManagedObjectContext: sharedContext) as! LetterSet
        // add the LetterSet to the GameData object
        letterset.game = game?.data //TODO: rename this game relationship to gameData?
        saveContext()
        letterset.letterSetID = String(letterset.objectID.URIRepresentation())
        
        game?.data?.currentLetterSetID = letterset.letterSetID
        // this should do the same as above, and much simpler
        // TODO: consider replacing the ID way of finding letterset
        game?.data?.currentLetterSet = letterset
        
        // make the LetterSet the letterset property for each Letter
        // and set the index for each letter for id'ing it later
        for i in 0 ..< letters.count {
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
    


    // Swift 2 version -- works but gives warning: AtoZModel.swift:237:23: 'var' parameters are deprecated and will be removed in Swift 3
    // creates a Letter object from a passed-in String, or generates a random 1 letter string if nil is passed in
//    func createLetter(var letterString: String?) -> Letter {
//        //TODO: test for validity of letter (e.g. what if it's a number, or more than 1 letter)
//        let alphabetArray = generateAlphabetArray()
//        if letterString == nil {
//            letterString = alphabetArray[Int(arc4random_uniform(UInt32(alphabetArray.count)))]
//        }
//        let letter = Letter(someLetter: letterString!, context: sharedContext)
//        //let letter = NSEntityDescription.insertNewObjectForEntityForName("Letter", inManagedObjectContext: sharedContext) as! Letter
//        return letter
//    }
    
    // Swift 3 version -- removed var parameter (which are deprecated in Swift 3) and replaced with var inside the func
    func createLetter(letterStringIn: String?) -> Letter {
        //TODO: test for validity of letter (e.g. what if it's a number, or more than 1 letter)
        var letterString = letterStringIn
        let alphabetArray = generateAlphabetArray()
        if letterString == nil {
            letterString = alphabetArray[Int(arc4random_uniform(UInt32(alphabetArray.count)))]
        }
        let letter = Letter(someLetter: letterString!, context: sharedContext)

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
    
    // get the 2 words used to get 6 of the 7 letters for a letterset
    // TODO: return one string of 6 letters instead of an array
    func getWordsForLetters () -> String {
        var wordsForLetters: String = ""
        var firstWordIndex: Int
        var secondWordIndex: Int

        
        let fetchRequest = NSFetchRequest(entityName: "Word")
        
        do {
            let fetchedWords = try sharedContext.executeFetchRequest(fetchRequest) as! [Word]
            let numUnsavedWords = wordsArray.count - fetchedWords.count
            
            switch fetchedWords.count {
                
            case 0: // no words have been saved

                // pick 2 random words from wordsArray
                firstWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
                secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
                wordsForLetters = wordsArray[firstWordIndex] + wordsArray[secondWordIndex]
                
                
            case wordsArray.count: // all words have been saved
                // need to pick from unmastered words
                var unmasteredWordsArray = [String]()
                
                for word in fetchedWords {
                    if word.mastered == false {
                        unmasteredWordsArray.append(word.word!)
                    }
                }
                
                switch unmasteredWordsArray.count {
                    
                case 0: // note -- repeating code under case 0 above
                    // pick 2 random words from wordsArray
                    firstWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
                    secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
                    wordsForLetters = wordsArray[firstWordIndex] + wordsArray[secondWordIndex]
                case 1:
                    firstWordIndex = Int(arc4random_uniform(UInt32(unmasteredWordsArray.count)))
                    secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
                    wordsForLetters = unmasteredWordsArray[firstWordIndex] + wordsArray[secondWordIndex]
                default: // 2 or more
                    // pick 2 random words from unmasteredWordsArray
                    firstWordIndex = Int(arc4random_uniform(UInt32(unmasteredWordsArray.count)))
                    secondWordIndex = Int(arc4random_uniform(UInt32(unmasteredWordsArray.count)))
                    wordsForLetters = unmasteredWordsArray[firstWordIndex] + unmasteredWordsArray[secondWordIndex]
                    
                }
//            case _ where numUnsavedWords == 1: // get the 1 unsaved word, and then find another word

            default:
                // some words have been saved, and >= 1 unsaved
                // need to get 2 random from the unsaved
                
                // Create a set of just the text(.word property) from the Word objects
                var savedWordsSet: Set<String> = Set<String>()
                
                for word in fetchedWords {
                    savedWordsSet.insert(word.word!)
                }
                
                // unsavedWords = wordsSet - savedWords
                let unsavedWordsSet = wordsSet.subtract(savedWordsSet)
                wordsForLetters = randomElementIndex(unsavedWordsSet)
                if  numUnsavedWords > 1 {
                    wordsForLetters += randomElementIndex(unsavedWordsSet)
                } else {
                    // only 1 from the unsaved, still need to add another word to the array
                    secondWordIndex = Int(arc4random_uniform(UInt32(wordsArray.count)))
                    wordsForLetters += wordsArray[secondWordIndex]
                }
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        print(wordsForLetters)
        return wordsForLetters
    }
    
    // helper function to get a random element from a set
    func randomElementIndex<T>(s: Set<T>) -> T {
        let n = Int(arc4random_uniform(UInt32(s.count)))
        let i = s.startIndex.advancedBy(n)
        return s[i]
    }
    
    func getWordlist(letters: [Letter]) -> [String] {
        
        
        var allLetterPermutationsSet = Set<String>()
        var sequence: String = ""
        
        // find all 210 possible permutations of 7 letters into 3 letter sequences, and add to a set
        // (call them 'sequences' as we don't know yet if they are words until they are checked against the 3 letter word list)
        for i in 0 ..< letters.count {
            
            // reset sequence so we start a new word on each loop of i
            sequence = ""
            for j in 0 ..< letters.count {
                if j != i { // a letter can be selected only once per word
                    for k in 0 ..< letters.count {
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
    
    //TODO:- add a func that takes the array of words from createOrUpdateWords, finds the mastered(if any), sorts them by level, and sets them to inactive starting from the highest level, continueing til inactive quota is reached.
    
    // either fetch or create Word managed objects for the current list, and update values to reflect their status
    func createOrUpdateWords(wordlist: [String]) -> [Word] {
        var currentWords = [Word]()
        // can I assume that a GameData has been created, and etc?
        // starting a new fetch request, in case none has been made, or it needs updating
        var newWord: Word
        //TODO:- keep the words sorted
        for i in 0 ..< wordlist.count {
       // for wordString in wordlist {
            let fetchRequest = NSFetchRequest(entityName: "Word")
            // Create Predicate
            let predicate = NSPredicate(format: "%K == %@", "word", wordlist[i])
            fetchRequest.predicate = predicate
            
            do {
                // not to be confused with global var wordsArray
                let wordArray = try sharedContext.executeFetchRequest(fetchRequest) as! [Word]
                // check to see if anything was returned
                if wordArray.count > 0 {
                    // a Word was returned for that String. Do not create another with the same string!
                    newWord = wordArray[0]
                } else {
                    newWord = Word(wordString: wordlist[i], context: sharedContext)
                    newWord.found = false
                }
                
                // Whether newly created, or fetched from existing, do the following:
                // assign letterset to the string
                // set inCurrentList to true
                // set found to false
                // add 1 to numTimesPlayed -- //TODO:-or add that in the VC?
                // set the game property
                newWord.game = game?.data // make sure that game is not nil
                // need to find the current letterset
                newWord.letterlist = game?.data?.currentLetterSet as? LetterSet //TODO: need to use ID to locate letterset?
                newWord.inCurrentList = true
                
                //newWord.numTimesPlayed += 1
                currentWords.append(newWord)
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
        }
        
        saveContext()
        //TODO:-- check currentWords for mastered words, and set to inactive up till inactive quota limit
        checkForInactiveWords(currentWords)
        
        return currentWords
 
    }
    
    func checkForInactiveWords(words: [Word]) {
        
        inactiveCount = 0 // need the # of inactive's so the VC can find out when a list is completed
        
        //create a array to hold the mastered words
        var masteredWords = [Word]()
    
        for word in words {
            if word.mastered == true {
                word.active = false
                masteredWords.append(word)
            }
            print(word.active)

            if word.active == false {
                print("::")
                print(word.word)
            }
        }
        saveContext()
        
        // check if # of mastered words is greater than inactive quota
        let iq = calculateInactiveQuota(words.count)
        print("iq: \(iq)")
        if masteredWords.count > iq {
            
            for _ in 0 ..< masteredWords.count {
                masteredWords.sortInPlace { $0.level > $1.level }
            }
            for i in 0 ..< masteredWords.count {
                print("\(masteredWords[i].word) : \(masteredWords[i].level)")
            }
            
            // for the sake of playability, set some of the words back to active
            // leaving the ones with the highest level (up til masteredWords[iq-1] as inactive
            for i in iq ..< masteredWords.count {
                masteredWords[i].active = true
            }
        }
        
        saveContext()
        
        for word in masteredWords {
            if word.active == false {
                inactiveCount! += 1
            }
        }
        
    }
    
    func getDefinition(word: String) -> String {
        if let definition = wordsDictionary[word] {
            return definition
        }
        
        return ("No definition was found for \(word)")
    }
    
    //MARK:- GameData funcs
    
    // Fetch the existing game from the store, or create one if there is none
    func fetchGame() -> Game {
        
        // TODO: determine which is the current game, and load that.
        // whereever current game is set to true, must set all others to be false
        // and have a safeguard that allows only one currentGame at a time
        let fetchRequest = NSFetchRequest(entityName: "Game")
        do {
            let gameArray = try sharedContext.executeFetchRequest(fetchRequest) as! [Game]
            if gameArray.count > 0 {
                for _ in 0 ..< 10 { // generalize to numberOfPositions var, instead of 10 
                    positions = gameArray[0].data?.positions?.allObjects as? [Position]
                    positions!.sortInPlace {
                        ($0.index as Int16?) < ($1.index as Int16?)
                    }
                }
                //TODO:- Set all other games' isCurrentGame to false here?
                //TODO:- add a predicate to fetch just the current game
                // A mechanism for adding a game has not yet been created
                return gameArray[0]
            } else { // there are no games, so create the first one
                //TODO: pass in dictionaryName from the GameType
                
                //let gameDataDictionary = makeGameDataDictionary()
                //let gameDataDictionary = [
               //     "name": "David Game 1",
               //     "isCurrentGame": true
              //  ]
                //let newGameData = GameData(dictionary: gameDataDictionary, context: sharedContext)
                let newGameData = NSEntityDescription.insertNewObjectForEntityForName("GameData", inManagedObjectContext: sharedContext) as! GameData
                newGameData.name = "Game-1"
                saveContext()
                //newGame.isCurrentGame = true
                
                let gameDictionary = makeGameDictionary()
            
                let newGame = Game(dictionary: gameDictionary, context: sharedContext)
                saveContext() // save the context so the URI becomes permanent, and can be used for ID
                newGame.gameID = String(newGame.objectID.URIRepresentation())
                newGame.data = newGameData
                newGame.gameTypeSet = GameType.ThreeLetterWords // default to 3 letter word game
                print ("newGame: \(newGame)")
                newGameData.game = newGame
                newGame.data?.isCurrentGame = true
                //TODO:- Set all other game isCurrentGame to false here?
                // TODO:= create a mechanism to add new a new game. Where?
                // create the Positions and add to game
                for i in 0 ..< 10 {
                    // create the Positions for the tiles. There are 10 per game.
                    // TODO: use init instead. And use Game object, which then has a GameData object
                    // Should Positions go with Game, or GameData??
                    let position = NSEntityDescription.insertNewObjectForEntityForName("Position", inManagedObjectContext: sharedContext) as! Position
                    position.index = Int16(i)
                    position.game = newGameData //store positions in Game instead?
                    positions?.append(position)
                    updateLetterPosition(i) // setting the coordinates
//                    let pos = generateLetterPosition(i)
//                    position.xPos = Float(pos.x)
//                    position.yPos = Float(pos.y)
                    
                    
                }
                saveContext()
                return newGame
            }
        // in the case there is a fetch error, also create a new game object
        } catch let error as NSError {
            print("Error in fetchGameData(): \(error)")
            //TODO: can the catch itself generate an error?
            // need to return a Game -- note: not saving context
            let defaultData = makeGameDataDictionary()
            let newData = GameData(dictionary: defaultData, context: sharedContext)
            let defaultGame = makeGameDictionary()
            let newGame = Game(dictionary: defaultGame, context: sharedContext)
            newGame.data = newData
            return newGame
        }
    }
    
    func updateLetterPosition(posIndex: Int) {
        let pos = generateLetterPosition(posIndex)
        positions![posIndex].xPos = Float(pos.x)
        positions![posIndex].yPos = Float(pos.y)
    }
    
    func updateLetterPositions() {
        for i in 0 ..< 10 {
            updateLetterPosition(i)
        }
        saveContext()
    }
    
    
    // might not be using this func

    
    func deleteGames() {
        let fetchRequest = NSFetchRequest(entityName: "GameData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try sharedContext.executeRequest(deleteRequest)
        } catch let error as NSError {
            print("Error in deleteMapInfo: \(error)")
        }
    }
    
    // make dict for Game values
    func makeGameDictionary() -> [String : AnyObject] {
        
        let gameDictionary = [
            "gameID": 0,
            "dictionaryName": "OSPD5_3letter",
            "gameType": 1
        ]
        //TODO: get the dictionaryName from the GameType
        
        return gameDictionary
    }
    
    // make dict for Game Data values
    func makeGameDataDictionary() -> [String : AnyObject] {
        
        let gameDataDictionary = [
            "name": "David Game 1",
            "isCurrentGame": true
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
    
    //MARK: - Calculation helpers
    
    // find the closest point to a given point
    func findClosestPosition(location: CGPoint, positionArray: [Position]) -> Position? {
        var closestPosition = positionArray[0]
        var lowestSquared = 99999999.0 // arbitrary largish number (ensure it's larger than the largest possible value of distance squared)
        //TODO: optimizations to reduce # of calculations
        for i in 0 ..< positionArray.count {
            if positionArray[i].letter == nil { // only check unoccupied poitions
                // no need to use sqrt to get distance. the square of the distance can be used for comparison purposes w/out having to calculate actual distance
                let distanceSquared = Double(pow(location.x - positionArray[i].position.x, 2) + pow(location.y - positionArray[i].position.y, 2))
                if distanceSquared <= lowestSquared {
                    closestPosition = positionArray[i]
                    lowestSquared = distanceSquared
                }
            }
        }
        return closestPosition
    }
 
    //TODO:- Remove if not using
//    func calculateDistance(p1: CGPoint, p2: CGPoint) -> Float {
//        let xDist = Float((p2.x - p1.x))
//        let yDist = Float((p2.y - p1.y))
//        return sqrt((xDist * xDist) + (yDist * yDist))
//    }
    
    // find the point from which to anchor the tiles and associated views
    func calculateAnchor(areaWidth: CGFloat, areaHeight: CGFloat, vertiShift: CGFloat, horizShift: CGFloat=0) -> CGPoint {
        anchorPoint =  (CGPointMake( areaWidth * 0.5 + horizShift, areaHeight + vertiShift ) )
        updateLetterPositions()
        return anchorPoint! // TODO: should not need to both return, and set the anchorPoint var
    }
    
    func generateLetterPosition(tileNum: Int) -> CGPoint {
        var xpos: CGFloat
        var ypos: CGFloat
        
        if anchorPoint == nil {
            anchorPoint = CGPointMake(130.0, 200.0)
        }
        
        switch tileNum {
            
        // counting from the bottom to the top
        case 0, 2:
            xpos = anchorPoint!.x + (CGFloat(tileNum - 1) * 59.0)
            ypos = anchorPoint!.y + CGFloat(330.0)
        case 1:
            xpos = anchorPoint!.x + (CGFloat(tileNum - 1) * 59.0)
            ypos = anchorPoint!.y + CGFloat(330.0) + 40.0
        case 3, 5:
            xpos = anchorPoint!.x + (CGFloat(tileNum - 4) * 64.0)
            ypos = anchorPoint!.y + CGFloat(270.0)
        case 4:
            xpos = anchorPoint!.x + (CGFloat(tileNum - 4) * 64.0)
            ypos = anchorPoint!.y + CGFloat(270.0) + 42.0
        case 6:
            xpos = anchorPoint!.x
            ypos = anchorPoint!.y + CGFloat(210.0) + 35.0
        case 7, 8, 9:
            xpos = anchorPoint!.x + CGFloat(tileNum - 8) * 60.0
            ypos = anchorPoint!.y + CGFloat(120.0)
        default:
            xpos = anchorPoint!.x
            ypos = anchorPoint!.y + CGFloat(200.0)
        }
        
        return CGPointMake(xpos, ypos)
    }
    
    func calculateInactiveQuota(wordlistCount: Int) -> Int {
        let inactiveFactor = 0.1  // arbitrary amount to give reasonable limits to max # inactives
        var inactiveQuota: Int = 0
        var tensPlace = Int(Double(wordlistCount) * 0.1)
        if (tensPlace > 3) { tensPlace -= 1 } // better distribution this way
        //for var i=0; i<=tensPlace; i += 1 {
        for _ in 0...tensPlace {
            inactiveQuota += (Int)(inactiveFactor * Double(wordlistCount))
        }
        return inactiveQuota
    }
    
//    // Obj-C version
//    - (int) calculateInactiveQuota : (int) wordlistCount {
//    float inactiveFactor = 0.1; // arbitrary amount to give reasonable limits to max # inactives
//    int inactiveQuota = 0;
//    int tensPlace = (int)(wordlistCount * 0.1);
//    if (tensPlace > 3) {
//    tensPlace -= 1; // better distribution this way
//    }
//    for (int i=0; i<=tensPlace; i++) {
//    inactiveQuota += (int)(inactiveFactor * wordlistCount);
//    }
//    NSLog(@"IQ is: %d", inactiveQuota);
//    return inactiveQuota;
//    }
    
    //MARK:- Stats calculations
  
    func numWordsFound() -> Int? {
        var numWords: Int16 = 0
        for aWord in (game?.data?.words)! {
            let w = aWord as? Word
            numWords += w!.numTimesFound
        }
        return Int(numWords)
    }
    
    func numWordsPlayed() -> Int? {
        var numWords: Int16 = 0
        for aWord in (game?.data?.words)! {
            let w = aWord as? Word
            numWords += w!.numTimesPlayed
        }
        return Int(numWords)
    }
    
    func numUniqueWordsFound() -> Int? {
        var numUniqueWords: Int16 = 0
        for aWord in (game?.data?.words)! {
            let w = aWord as? Word
            if w?.numTimesFound > 0 {
                numUniqueWords += 1
            }
        }
        return Int(numUniqueWords)
    }
    
    func numUniqueWordsPlayed() -> Int? {
        var numUniqueWords: Int16 = 0
        for aWord in (game?.data?.words)! {
            let w = aWord as? Word
            if w?.numTimesPlayed > 0 {
                numUniqueWords += 1
            }
        }
        return Int(numUniqueWords)
    }
    
    
    
    func percentageFound() -> Int? {
        guard let numWordsPlayed = numWordsPlayed() else {
            return nil
        }
        guard let numWordsFound = numWordsFound() else {
            return nil
        }
        if numWordsPlayed > 0 {
            return Int(100.0 * Float(numWordsFound) / Float(numWordsPlayed))
        } else {
            return nil
        }
    }
    
    func randomize7() -> [Int] {
        let sevenInts = [0,1,2,3,4,5,6]
        return GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(sevenInts) as! [Int]
         //GKMersenneTwisterRandomSource // more randomized but slower method
    }
    
    func printStats() {
        print("***********STATS****************")
        print("You have found \(numWordsFound()!) words out of \(numWordsPlayed()!) words played")
        print("Your percentage: \(percentageFound()!)%")
        print("You have found \(numUniqueWordsFound()!) unique words out of the \(numUniqueWordsPlayed()!) unique words played from a dictionary of \(wordsArray.count) three letter words")
    }
    
    
    //TODO: What about word 'mastery'?
    
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
    
    //MARK:- Colors
//    
//    struct Colors {
//        
//        static let magenta = UIColor(hue: 300/360, saturation: 1.0, brightness: 0.7, alpha: 1.0)
//        
//    }
}


