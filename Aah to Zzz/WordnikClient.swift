//
//  WordnikClient.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/27/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//
//  Client to get network data through the Wordnik API
//  words definitions and examples of use in a sentence

//import Foundation
import CoreData

let BASE_URL                    = "http://api.wordnik.com:80/v4/word.json/"
let METHOD_NAME                 = "definitions"
let LIMIT                       = "25"
let INCLUDE_RELATED             = "false"
let SOURCE_DICTIONARIES         = "all" //"ahd"//(american heritage dictionary)
let USE_CANONICAL               = "true" // tells Wordnik look at the root of the word, for instance, if the word is "AAS", it would look at it as the plural of "AA"
let INCLUDE_TAGS                = "false"
let API_KEY                     = "c6c759673ee70a17150040157a20fb5c0cc0963c68720e422" // David's wordnik API key

class WordnikClient: NSObject {
    
    //MARK:- Vars
    static let sharedInstance = WordnikClient() // makes this class a singleton
    let model                 = AtoZModel.sharedInstance
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    // used in the DefinitionPopover to get info from the net to add to the list of definitions
    func getDefinitionForWord(_ word: String, completionHandler: @escaping (_ response: URLResponse?, _ definitions: [String]?, _ success: Bool, _ errorString: String?) -> Void) {
    
    //  API method arguments
    let methodArguments = [
        "limit":                LIMIT,
        "includeRelated":       INCLUDE_RELATED,
        "sourceDictionaries":   SOURCE_DICTIONARIES,
        "useCanonical":         USE_CANONICAL,
        "includeTags":          INCLUDE_TAGS,
        "api_key":              API_KEY
        ]
        
        // Initialize session and url
        let session = URLSession.shared
        let urlString = BASE_URL + word + "/" + METHOD_NAME + escapedParameters(methodArguments as [String : AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // Initialize task for getting data
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard (response != nil) else {
                completionHandler(response, nil, false, String(describing: error))
                return
            }
            // Check for a successful response
            // GUARD: Was there an error?
            guard (error == nil) else {
                completionHandler(response, nil, false, String(describing: error))
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    completionHandler(response, nil, false, "Tried to get definitions but there was an error: Status code \(response.statusCode)")
                } else if let response = response {
                    completionHandler(response, nil, false, "Tried to get definitions but there was an error: \(response)")
                } else {
                    completionHandler(response, nil, false, "Tried to get definitions but there was an invalid response.")
                }
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                completionHandler(response, nil, false, "No data was found.")
                return
            }
            
            // - Parse the data
            let parsedResult: [[String:Any]]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:Any]]
                
                guard let definitionsJSON = parsedResult
                    else {
                        return
                }
                
                var definitions = [String]()
                for def in definitionsJSON {
                    if let definition = def["text"] as? String {
                        definitions.append(definition)
                    }
                }
                completionHandler(response, definitions, true, nil)
            } catch {
                parsedResult = nil
                completionHandler(response, nil, false, "Could not parse a result")
                return
            }
        }) 
        task.resume()
    }
    
    
        //MARK: Helper functions
        
        // Given a dictionary of parameters, convert to a string for a url */
        func escapedParameters(_ parameters: [String : AnyObject]) -> String {
            
            var urlVars = [String]()
            
            for (key, value) in parameters {
                
                /* Make sure that it is a string value */
                let stringValue = "\(value)"
                
                /* Escape it */
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
                
            }
            
            return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
        }

    // Wordnik example requests
    /* // Example GET request for a definition (of "hit")
    http://api.wordnik.com:80/v4/word.json/hit/definitions?limit=200&includeRelated=true&sourceDictionaries=all&useCanonical=true&includeTags=false&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
    */
    
    /* // Example GET request for examples (of "cat")
    http://api.wordnik.com:80/v4/word.json/cat/examples?includeDuplicates=false&useCanonical=true&skip=0&limit=5&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
    */
    
    /* // Example GET request for top example (of "cat")
    http://api.wordnik.com:80/v4/word.json/cat/topExample?useCanonical=true&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
    */

}
