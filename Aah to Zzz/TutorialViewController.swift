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
    var bubbleIndex:            Int                     = 0
    var numBubbles:             Int                     = 0
    var arrowStartPoints:       [CGPoint]               = []
    var arrowEndPoints:         [CGPoint]               = [] // load from main VC on instantiation
    weak var currentBubble:     ArrowView?
    
    // Consider adding an offset to the Struct, whch would dictate the position of start (relative to end)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a dismiss button
        addDismissButton()
        // add gesture to display the next bubble
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer: )))
        view.addGestureRecognizer(tapGesture)
        
        let bubbleMessages = getBubbleMessages()
        print("BM COUHNT: \(bubbleMessages.count)")
        
        print("BBMSSG!-------\(bubbleMessages)")
        //getArrowStartPoints() // not yet implemented

        print("COUNTING: \(arrowEndPoints.count)")
        
        // Set the number of bubbles to the lesser of # endpts, or # messages
        numBubbles = arrowEndPoints.count
        print("BM COUHNT: \(bubbleMessages.count)")
        if bubbleMessages.count < numBubbles {
            numBubbles = bubbleMessages.count
        }
    
        for i in 0 ..< numBubbles {

            // generate the start points
            let startPoint = CGPoint(x: arrowEndPoints[i].x - 30.0,
                                     y: arrowEndPoints[i].y - 70.0)
            arrowStartPoints.append(startPoint)
                
            let data = BubbleData(startPoint: arrowStartPoints[i], endPoint: arrowEndPoints[i], text: bubbleMessages[i])
            bubbleData.append(data)
            
        }
        
        displayNextBubble()
        
    }
    
    func addDismissButton() {
        let buttonWidth: CGFloat = 210.0
        let buttonFrame = CGRect(x: 0.5 * (view.bounds.width - buttonWidth), y: 12, width: buttonWidth, height: 36.0)
        let dismiss = UIButton(frame: buttonFrame)
        dismiss.setTitle("Close Tutorial", for: .normal)
        dismiss.backgroundColor = .green
    
        dismiss.addTarget(self, action: #selector(dismissThis(sender:)), for: .touchUpInside)

        view.addSubview(dismiss)
    }
    
    @objc func dismissThis(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        displayNextBubble()
    }
    
    func displayNextBubble() {
        print ("NEXT BUBBLE")
        // nedd to display  first bubb
        // get the current bubble index -- set to 0 as default at start
        
        if bubbleIndex > 0  && bubbleIndex < numBubbles {
            // remove the current bubble
            currentBubble?.removeFromSuperview()
        }
        // check if the index is the last one. If so, dismiss the view controller
        if bubbleIndex == numBubbles {
            self.dismiss(animated: true, completion: nil)
            return
        }
        // create and load the new current bubble
        if bubbleIndex < numBubbles {
            displayBubble(index: bubbleIndex)
            // increment the index
            bubbleIndex += 1
        }

    }
    
    func displayBubble(index: Int) {
        let arrowBubble = ArrowView(arrowType: .straight, startPoint: arrowStartPoints[index], endPoint: arrowEndPoints[index], startWidth: 11, endWidth: 5, arrowWidth: 25, arrowHeight: 12, blurriness: 0.5, shadowWidth: 2.5, bubbleWidth: 20, bubbleHeight: 80, bubbleType: .rectangle, bubbleDelegate: BubbleDelegate(), bubbleData: bubbleData[index])

//        guard let currentBubble = self.currentBubble else {
//            return
//        }
        currentBubble = arrowBubble

        view.addSubview(arrowBubble)

    }
    
    func getArrowStartPoints() {
        // Use the end points to get the start points
        // should have overrides for customization
    }

    // Set the text for the messages
    // could move to a static struct?
    func getBubbleMessages() -> [[String]] {
        var bubbleMessages = [[String]]()
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
