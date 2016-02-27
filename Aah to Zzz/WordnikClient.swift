//
//  WordnikClient.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/27/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//
//  Client to get network data through the Wordnik API
//  words definitions and examples of use in a sentence

import Foundation
import CoreData

let BASE_URL = "http://api.wordnik.com:80/v4/word.json/"

let METHOD_NAME = "definitions"
let LIMIT = "200"
let INCLUDE_RELATED = "true"
let SOURCE_DICTIONARIES = "all"
let USE_CANONICAL = "true"
let INCLUDE_TAGS = "false"
let API_KEY = "c6c759673ee70a17150040157a20fb5c0cc0963c68720e422" // David's wordnik API key

class WordnikClient: NSObject {
    
    // Example requests
    /* // Example GET request for a definition (of "hit")
    http://api.wordnik.com:80/v4/word.json/hit/definitions?limit=200&includeRelated=true&sourceDictionaries=all&useCanonical=true&includeTags=false&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
    */
    /* // Example GET request for top example (of "cat")
    http://api.wordnik.com:80/v4/word.json/cat/topExample?useCanonical=true&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
    */
    /* // Example GET request for examples (of "cat")
    http://api.wordnik.com:80/v4/word.json/cat/examples?includeDuplicates=false&useCanonical=true&skip=0&limit=5&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
    */
    
    //MARK:- Vars
    static let sharedInstance = WordnikClient() // makes this class a singleton
    let model = AtoZModel.sharedInstance
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
//    var totalPhotos: Int?
//    var currentAccuracy: Int = ACCURACY_DEFAULT
//    var noPhotosCanBeFound: Bool = false

    
    func getDefinitionForWord(word: String) -> String {
    
    //  API method arguments
    let methodArguments = [
        "limit": LIMIT,
        "includeRelated": INCLUDE_RELATED,
        "sourceDictionaries" : SOURCE_DICTIONARIES,
        "useCanonical": USE_CANONICAL,
        "includeTags": INCLUDE_TAGS,
        "api_key": API_KEY
        ]
        
        // Initialize session and url
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + word + "/" + METHOD_NAME + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // Initialize task for getting data
        print(urlString)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Check for a successful response
            // GUARD: Was there an error?
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // - Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
        }
        task.resume()
        return word // TODO: to be replaced by definition
    }
    
    
        //MARK: Helper functions
        
        // Given a dictionary of parameters, convert to a string for a url */
        func escapedParameters(parameters: [String : AnyObject]) -> String {
            
            var urlVars = [String]()
            
            for (key, value) in parameters {
                
                /* Make sure that it is a string value */
                let stringValue = "\(value)"
                
                /* Escape it */
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
                
            }
            
            return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
        }



}