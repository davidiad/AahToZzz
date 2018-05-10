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
        print("COUNTING: \(arrowEndPoints.count)")
            for i in 0 ..< arrowEndPoints.count {
                if i < 3 { // temp check TODO: fix -- finding 12 end points?
                    
                
                    // generate the start points
                    let startPoint = CGPoint(x: arrowEndPoints[i].x - 30.0,
                                         y: arrowEndPoints[i].y - 70.0)
                    arrowStartPoints.append(startPoint)
                    let data = BubbleData(startPoint: arrowStartPoints[i], endPoint: arrowEndPoints[i], text: bubbleMessages[i])
                    bubbleData.append(data)
                    let arrowBubble = ArrowView(arrowType: .straight, startPoint: arrowStartPoints[i], endPoint: arrowEndPoints[i], startWidth: 11, endWidth: 5, arrowWidth: 25, arrowHeight: 12, blurriness: 0.5, shadowWidth: 2.5, bubbleWidth: 20, bubbleHeight: 80, bubbleType: .rectangle, bubbleDelegate: BubbleDelegate(), bubbleData: bubbleData[i])
                    view.addSubview(arrowBubble)
                }
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
    // could move to a static struct?
    func getBubbleMessages() -> [[String]] {
        var bubbleMessages: [[String]] = [[]]
        bubbleMessages.append(["First", "Second Line", "third"])
        bubbleMessages.append(["Tap", "New List Button", "to get new words"])
        bubbleMessages.append(["a word"])
        
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
