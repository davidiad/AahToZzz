//
//  TutorialViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/7/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    var bubbleData:             [BubbleData]            = []
    var arrowStartPoints:       [CGPoint]               = []
    var arrowEndPoints:         [CGPoint]               = [] // load from main VC on instantiation
    // Consider adding an offset to the Struct, whch would dictate the position of start (relative to end)
    override func viewDidLoad() {
        super.viewDidLoad()
        let bubbleMessages = getBubbleMessages()
        //getArrowStartPoints() // not yet implemented
        //if arrowEndPoints.count == bubbleMessages.count {
            for i in 0 ..< arrowEndPoints.count {
                // generate the start points
                let startPoint = CGPoint(x: arrowEndPoints[i].x - 20.0,
                                         y: arrowEndPoints[i].y - 40.0)
                arrowStartPoints.append(startPoint)
                let data = BubbleData(startPoint: arrowStartPoints[i], endPoint: arrowEndPoints[i], text: bubbleMessages[i])
                bubbleData.append(data)
            }
        //}
        
        // create a new ArrowView using each bubbleData in the array BubbleData, and add to view
        // Later, instead of adding to view, animate each one in separately, on a click
        // Add an X or Done button to dismiss the tutorial at any time
        
    }
    
    func getArrowStartPoints() {
        // Use the end points to get the start points
        // should have overrides for customization
    }

    // Set the text for the messages
    func getBubbleMessages() -> [[String]] {
        var bubbleMessages: [[String]] = [[]]
        bubbleMessages.append(["First", "Second Line", "third"])
        bubbleMessages.append(["Tap", "New List Button", "to get new words"])
        bubbleMessages.append(["Tap", "a word", "to get definition"])
        
        return bubbleMessages
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
