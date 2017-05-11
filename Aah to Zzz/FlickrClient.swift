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
let PER_PAGE_DEFAULT = 10
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
    
    func getFlickrImagesForWord(_ searchtext: String, completion: @escaping (_ ius: String?, _ success: Bool, _ error: NSError?) -> Void) {
        
        let page = "1"
        photoArray = [String]()
        
        
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
        ] as [String : Any]
        
        // Initialize session and url
        let session = URLSession.shared
        let urlString = FLICKR_BASE_URL + escapedParameters(methodArguments as [String : AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // Initialize task for getting data
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard (response != nil) else {
                completion(nil, false, error as! NSError)
                return
            }
            // Check for a successful response
            // GUARD: Was there an error?
            guard (error == nil) else {
                completion(nil, false, error as! NSError)
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completion(nil, false, error as! NSError)
                    
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                completion(nil, false, error! as NSError)
                return
            }
            
            // - Parse the data
            let parsedResult: [String:Any]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            } catch {
                parsedResult = nil
                completion(nil, false, nil)
                return
            }
            
            // GUARD: Are the "photos" and "photo" keys in our result?
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary,
                let photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    completion(nil, false, error as! NSError)
                    return
            }
            
            if photoArray.count > 0 {
                let examplePhoto = photoArray.first
                guard let imageUrlString = examplePhoto![EXTRAS] as? String else {
                    // handle error
                    completion(nil, false, error as! NSError)
                    return
                }
                
                completion(imageUrlString, true, error as! NSError)
            } else {
                completion(nil, false, nil)
            }
        }) 
        
        
        // Resume (execute) the task
        task.resume()
    }
    
    // Task method for downloading individual images
    func taskForImage(_ filePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {
        let url = URL(string: filePath)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(nil, error as NSError)
            } else {
                completionHandler(data, nil)
            }
        }) 
        task.resume()
        
        return task
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

