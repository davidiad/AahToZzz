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
        arrowDirections.append(.downright)
        adjustFactors.append((1,1))
        arrowDirections.append(.upright)
        adjustFactors.append((1,1))
        arrowDirections.append(.upleft)
        adjustFactors.append((2.3,1))
        arrowDirections.append(.upleft)
        adjustFactors.append((1.5,1))
        arrowDirections.append(.downleft)
        adjustFactors.append((2,1))
        arrowDirections.append(.downright)
        adjustFactors.append((2,1))
        arrowDirections.append(.down)
        adjustFactors.append((1,1.15))
        arrowDirections.append(.down)
        adjustFactors.append((1,1.15))
        arrowDirections.append(.down)
        adjustFactors.append((1,1.15))
        arrowDirections.append(.down)
        adjustFactors.append((1,1.15))
        
        for i in 0 ..< numBubbles {
            
            let data = BubbleData(text: bubbleMessages[i],
                                  endPoint: arrowEndPoints[i],
                                  direction: arrowDirections[i],
                                  adjustFactor: adjustFactors[i] )
            bubbleData.append(data)
            
        }
        
        displayBubble(index: 0)
        
    }
    
    // Set the text for the messages
    // could move to a static struct?
    func getBubbleMessages() -> [[String]] {
        var bubbleMessages = [[String]]()
        bubbleMessages.append(["Find all the", "3 letter words", "in these 7 tiles"])
        bubbleMessages.append(["Tap or drag", "the tiles", "to form words"])
        bubbleMessages.append(["Valid words", "are moved", "to the", "found word list"])
        bubbleMessages.append(["Tap a word", "to see definition"])
        bubbleMessages.append(["Scroll up or down", "to see", "all the words", "in your list"])
        bubbleMessages.append(["Dragging up or down", "on the right edge", "of the screen", "also scrolls the word list" ])
        bubbleMessages.append(["Tap", "the Cheat Button", "to fill in the words automatically", "(You will lose points!)"])
        bubbleMessages.append(["Tap", "the New List Button", "for a new list of words to find"])
        bubbleMessages.append(["Tap", "the Progress Button", "to see your progress graph", "and to check Leaderboards"])
        bubbleMessages.append(["Tap", "the Jumble Button", "to rearrange the tiles"])
        return bubbleMessages
    }
    
    func addDismissButton() {
        let buttonWidth: CGFloat = 150.0
        let buttonFrame = CGRect(x: 0.5 * (view.bounds.width - buttonWidth), y: 12, width: buttonWidth, height: 36.0)
        let buttonView = ShapeView(frame: buttonFrame, blurriness: 0.8, shadowWidth: 1.3)
        let dismiss = UIButton(frame: buttonFrame)
        dismiss.setTitleColor(.black, for: .normal)
        dismiss.setTitleColor(Colors.sat_blue, for: .highlighted)
        dismiss.setTitle("Close Tutorial  x", for: .normal)
        dismiss.addTarget(self, action: #selector(dismissThis(sender:)), for: .touchUpInside)
        buttonView.addSubview(dismiss)
        view.addSubview(buttonView)
        
    }
    
    @objc func dismissThis(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        displayNextBubble()
    }
    
    func displayNextBubble() {

        if bubbleIndex < numBubbles {
            // fade out the current msg bubble
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
                self.currentBubble?.alpha = 0.0
            }) { (_) in
                // remove the current bubble and add the next one
                self.currentBubble?.removeFromSuperview()
                self.displayBubble(index: self.bubbleIndex)
            }
        }
        // check if the index is the last one. If so, dismiss the view controller
        if bubbleIndex == numBubbles {
            self.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    func displayBubble(index: Int) {
        let arrowBubble = ArrowView(arrowType: .straight, endPoint: arrowEndPoints[index], startWidth: 12, endWidth: 4, arrowWidth: 16, arrowHeight: 29, blurriness: 0.55, shadowWidth: 12.5, bubbleWidth: 20, bubbleHeight: 80, bubbleType: .rectangle, bubbleDelegate: BubbleDelegate(), bubbleData: bubbleData[index])
        
        currentBubble = arrowBubble
        arrowBubble.alpha = 0.0
        view.addSubview(arrowBubble)
        // fade in the bubble
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
            arrowBubble.alpha = 1.0
        })
        bubbleIndex += 1 // get ready for the next bubb
    }
}
