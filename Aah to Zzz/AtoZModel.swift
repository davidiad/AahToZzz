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
        for var i = 0; i < rawWordsArray.count - 1; i = i + 2 {
            let key = rawWordsArray[i]
            let value = rawWordsArray[i + 1]
            
            wordsArray.append(key)
            wordsDictionary[key] = value
        }
        // temp. to check it's working
        generateWordList()
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
    func generateWordList () {
        let letters = generateLetters()
        getLetterPermutations(letters)
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
    
    
    
    // find all 210 possible permutations of 7 letters into 3 letter sequences, and add to a set
    // (call them 'sequences' as we don't know yet if they are words until they are checked against the 3 letter word list)
    func getLetterPermutations(letters: [String]) -> Set<String> {
        // consider turning dictionaryArray into a set in order to quickly intersect with this set
        // then, would probably want to convert the result back to an array so it can be ordered and used as data source in the table.
        var allLetterPermutationsSet = Set<String>()
        var sequence: String = ""
        var sequenceCounter: Int = 0
        
        print("letters: \(letters)")
        
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
        print(sequenceCounter)
        /* //Objective-C version
        for (int i = 0; i < 7; i++) {
            //add first letter
            word = [[NSMutableString alloc] initWithFormat:@""];
            [word appendString: [startingArray objectAtIndex:i]];
            for (int j = 0; j< 7; j++)
            {
                if (j!=i)
                {
                    //add second letter
                    if (word.length > 2) {
                        NSRange range;
                        range.location = 1;
                        range.length = 2;
                        [word deleteCharactersInRange:range];
                    }
                    [word appendString:[startingArray objectAtIndex:j]];
                    //NSLog(@"  %ith 2nd letter added in loop", j);
                }
                for (int k = 0; k < 7; k++)
                {
                    if (j!=i && k!=j && k!=i) 
                    {
                        //add third letter
                        if (word.length > 2) {
                            NSRange range;
                            range.location = 2;
                            range.length = 1;
                            [word deleteCharactersInRange:range];
                        }
*/
        
        
        print("set: \(allLetterPermutationsSet)")
        print("set count: \(allLetterPermutationsSet.count)")
        return allLetterPermutationsSet
    }

}


