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
    
    var wordsDictionary: [String: String]
    
    //This prevents others from using the default '()' initializer for this class.
    private init() { 
        wordsDictionary = ["AAH" : "to exclaim in delight", "AAL" : "East Indian shrub"]
        let wordsArray = arrayFromContentsOfFileWithName("3letterwordlist")
        
        // convert wordsArray to wordsDictionary
        // even elements of wordsArray are the keys (the word itself); odd entries are the values, which are the word definitions
        for var index = 0; index < wordsArray!.count - 1; index = index + 2 {
            let key = wordsArray![index]
            let value = wordsArray![index + 1]

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

}


