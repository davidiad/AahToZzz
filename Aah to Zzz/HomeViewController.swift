//
//  HomeViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/6/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var buttonHolderView: UIView!
    
    @IBAction func playGame(_ sender: AnyObject) {
       // performSegueWithIdentifier("PlaySegue", sender:self)
    }
    

    @IBOutlet weak var rightSideBar: UIImageView!
    
    //MARK:- Constants
    // 1st bubble
    let NUMLINES1 = 3
    let BUBBLETEXT1 = "A fun way to learn 3 letter words."
    let BUBBLETEXT2 = "Tap or drag the letters to form words."
    let BUBBLETEXT3 = "Keep going till you find all 1000+ 3 letter words!"
    // 2nd bubble
    let NUMLINES2 = 1
    let BUBBLETEXT4 = "3 > 1+2!!!"
    
    //MARK:- Vars
    var blurredViews: [BlurViewController] = []
    
    // Pass text info to blurred background VC's
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bubble = segue.destination as? BlurViewController else {
            return
        }
        
        if segue.identifier == "Blurred1" {
            blurredViews.append(bubble)
            // Since we do not know in which order the controllers are added to blurredViews,
            // set the index to the element just added to the array
            let index = blurredViews.count - 1
            blurredViews[index].numLines = NUMLINES1
            blurredViews[index].textLines.append(BUBBLETEXT1)
            blurredViews[index].textLines.append(BUBBLETEXT2)
            blurredViews[index].textLines.append(BUBBLETEXT3)
            blurredViews[index].textAsButtons = true
            
        } else if segue.identifier == "Blurred2" {
            blurredViews.append(bubble)
            let index = blurredViews.count - 1
            blurredViews[index].numLines = NUMLINES2
            blurredViews[index].textLines.append(BUBBLETEXT4)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBar()
        descriptionView.layer.cornerRadius = 12.0
        descriptionView.layer.masksToBounds = true
        buttonHolderView.layer.cornerRadius = 12.0
        buttonHolderView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    // TODO: repeated in Progress VC. Consolidate.
    func addGradientBar() {
        let gradient = model.yellowPinkBlueGreenGradient()
        //gradient.frame = rightSideBar.frame
        //gradient.frame = CGRectMake(rightSideBar.frame.origin.x, rightSideBar.frame.origin.y, 60, view.bounds.height)
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        rightSideBar.layer.addSublayer(gradient) 
    }

}
