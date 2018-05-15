//
//  TutorialViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/7/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    var bubbleData:             [BubbleData]               = []
    var bubbleIndex:            Int                        = 0
    var numBubbles:             Int                        = 0
    var arrowStartPoints:       [CGPoint]                  = []
    var arrowEndPoints:         [CGPoint]                  = [] // load from main VC on instantiation
    var arrowDirections:        [ArrowDirection]           = []
    var adjustFactors:          [(x: CGFloat, y: CGFloat)] = []
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
        
        // Set the number of bubbles to the lesser of # endpts, or # messages
        numBubbles = arrowEndPoints.count

        if bubbleMessages.count < numBubbles {
            numBubbles = bubbleMessages.count
        }
        arrowDirections.append(.upright)
        adjustFactors.append((1,1))
        arrowDirections.append(.upleft)
        adjustFactors.append((1.8,0.5))
        arrowDirections.append(.down)
        adjustFactors.append((1,1))
        
        for i in 0 ..< numBubbles {
            
            let data = BubbleData(text: bubbleMessages[i],
                                  endPoint: arrowEndPoints[i],
                                  direction: arrowDirections[i],
                                  adjustFactor: adjustFactors[i] )
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
        let arrowBubble = ArrowView(arrowType: .straight, endPoint: arrowEndPoints[index], startWidth: 10, endWidth: 4, arrowWidth: 19, arrowHeight: 12, blurriness: 0.5, shadowWidth: 2.5, bubbleWidth: 20, bubbleHeight: 80, bubbleType: .quadcurve, bubbleDelegate: BubbleDelegate(), bubbleData: bubbleData[index])

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
        bubbleMessages.append(["First", "Second Line", "third", "fourth"])
        bubbleMessages.append(["Tap a word", "to see its definition this line is too long"])
        bubbleMessages.append(["Tap", "the New List Button", "for new words a very long line!"])
        
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
