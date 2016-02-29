//
//  FlickrClient.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/28/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//


import UIKit
import CoreData

let FLICKR_BASE_URL = "https://api.flickr.com/services/rest/"
let FLICKR_METHOD_NAME = "flickr.photos.search"
let FLICKR_API_KEY = "fbbfff74562ae3fad94ecb8163cfd5a8"
let EXTRAS = "url_m"
let CONTENT_TYPE = "1"
let MEDIA = "photos"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let ACCURACY_DEFAULT = 9
let PER_PAGE_DEFAULT = 200
let RADIUS_DEFAULT = "32" // 32 is max allowed, in km
let SORT = "relevance"

class FlickrClient: NSObject {
    
    //MARK:- Vars
    static let sharedInstance = FlickrClient() // makes this class a singleton
    let model = AtoZModel.sharedInstance
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    var totalPhotos: Int?
   
    var photoArray: [String]?
    
    
    //MARK:- Flickr image fetch functions
    // When getTotal is true, only fetching the total # of photos
    // When getTotal is false, actually fetching the photos
    func getFlickrImagesForWord(searchtext: String, completion: (ius: String?, success: Bool, error: NSError?) -> Void) {
        
//        var text: String = ""
//        text = searchtext
        let page = "1"
//        if searchtext != nil {
//            text = "\(searchtext!)"
//        }
        photoArray = [String]()
        
//        let min_date_upload = {
//            // As accuracy is decreased, makeDate() increases the date range as well
//            makeDate()
//        }()
        
        
        //  API method arguments
        let methodArguments = [
            "method": FLICKR_METHOD_NAME,
            "api_key": FLICKR_API_KEY,
            "text": searchtext,
            "accuracy": ACCURACY_DEFAULT,
            "content_type": CONTENT_TYPE,
            "media": MEDIA,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "per_page": PER_PAGE_DEFAULT,
            "page": page,
            "sort": SORT
        ]
        
        // Initialize session and url
        let session = NSURLSession.sharedSession()
        let urlString = FLICKR_BASE_URL + escapedParameters(methodArguments as! [String : AnyObject])
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        // Initialize task for getting data
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (response != nil) else {
                completion(ius: nil, success: false, error: error)
                return
            }
            // Check for a successful response
            // GUARD: Was there an error?
            guard (error == nil) else {
                completion(ius: nil, success: false, error: error)
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completion(ius: nil, success: false, error: error)
                    
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                completion(ius: nil, success: false, error: error)
                return
            }
            
            // - Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                //print("Could not parse the data as JSON: '\(data)'")
                completion(ius: nil, success: false, error: nil)
                return
            }
            
//            // GUARD: Did Flickr return an error (stat != ok)?
//            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
//                print("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
            
            // GUARD: Are the "photos" and "photo" keys in our result?
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary,
                photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    completion(ius: nil, success: false, error: error)
                    return
            }
            
            if photoArray.count > 0 {
                let examplePhoto = photoArray.first
                guard let imageUrlString = examplePhoto!["url_m"] as? String else {
                    // handle error
//                    print("Cannot find key 'url_m' in \(examplePhoto)")
                    completion(ius: nil, success: false, error: error)
                    return
                }
                completion(ius: imageUrlString, success: true, error: error)
            } else {
                completion(ius: nil, success: false, error: nil)
            }
        }
        
        
        // Resume (execute) the task
        task.resume()
    }
    
    // Task method for downloading individual images
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
        
        return task
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
    
    
/* Flickr extras reference:
url_c URL of medium 800, 800 on longest size image
url_m URL of small, medium size image
url_n URL of small, 320 on longest side size image
url_o URL of original size image
url_q URL of large square 150x150 size image
url_s URL of small suqare 75x75 size image
url_sq URL of square size image
url_t URL of thumbnail, 100 on longest side size image
*/
}

