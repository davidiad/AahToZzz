//
//  DefinitionPopoverVC.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/26/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class DefinitionPopoverVC: UIViewController {
    
    let wordnik = WordnikClient.sharedInstance
    let flickr = FlickrClient.sharedInstance
    
    var sometext: String? //TODO: give 'sometext' a better variable name!
    var definition: String? // Holds the definition from the OSPD4 dictionary in the original word list
    
    @IBOutlet weak var exampleImage: UIImageView!
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var networkDefinitionsTV: UITextView!
    
    @IBOutlet weak var currentWord: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var flickrActivityView: UIActivityIndicatorView!
    
    @IBOutlet weak var flickrMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentWord.text = "DFault"
        if sometext != nil {
            currentWord.text = sometext
        }

        if definition != nil {
            definitionTextView.text = definition
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if sometext != nil {
            
            wordnik.getDefinitionForWord(sometext!) { response, definitions, success, errorString in
                if response != nil {
                    
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityView.stopAnimating()
                            var networkDefinitions: String = ""
                            if definitions != nil {
                                for def in definitions! {
                                    networkDefinitions += def
                                    networkDefinitions += "\n\n"
                                }
                                // the case where definitions exist, but holds no values
                                if definitions!.count == 0 {
                                    networkDefinitions += "There are no more definitions for '\(self.sometext!)' found on Wordnik."
                                }
                            }
                            self.networkDefinitionsTV.text = networkDefinitions
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityView.stopAnimating()
                            self.networkDefinitionsTV.text = errorString
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityView.stopAnimating()
                        self.networkDefinitionsTV.text = "More definitions may be available on the net, but the internet connection appears to be offline"
                    }
                }
            }
            flickr.getFlickrImagesForWord(sometext!) {ius, success, error in
                if success {
                    _ = self.flickr.taskForImage(ius!) { data, error in
                        if let error = error {
                            self.flickrActivityView.stopAnimating()
                            self.flickrMessage.text = "Photo download error: \(error.localizedDescription)"
                        }
                        if let data = data {
                            // Create the image
                            let image = UIImage(data: data)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.flickrMessage.text = ""
                                self.flickrActivityView.stopAnimating()
                                self.exampleImage.image = image
                            }
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.flickrActivityView.stopAnimating()
                        self.flickrMessage.text = "Not successful in finding an example image"
                    }
                }
            }
        }
    }

}
