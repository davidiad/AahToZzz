//
//  HomeViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/6/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleViewHolder: UIView!
    
    @IBOutlet weak var descriptionView: UIView!
    
//    @IBOutlet weak var buttonHolderView: UIView!
    
    @IBOutlet var buttons: [UIButton]!
    
    
    @IBAction func playGame(_ sender: AnyObject) {
       // performSegueWithIdentifier("PlaySegue", sender:self)
    }
    
    @IBOutlet weak var rightSideBar: UIImageView!
    
    //MARK:- Constants
    // 1st bubble
    let bubbleText1: [String] = ["Why 3 letter words?",
                                 "A fun way to learn 3 letter words.",
                                 "Keep going till you find all 1000+ 3 letter words!"]
//    let NUMLINES1 = 3
//    let BUBBLETEXT1 = "Why 3 letter words?"
//    let BUBBLETEXT2 = "A fun way to learn 3 letter words."
//    let BUBBLETEXT3 = "Keep going till you find all 1000+ 3 letter words!"
//    // 2nd bubble
//    let NUMLINES2 = 1
//    let BUBBLETEXT4 = "3 > 1+2!!!"
    
    //MARK:- Vars
    var blurredViews: [BlurViewController] = []
    
    // Pass text info to blurred background VC's
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bubble = segue.destination as? BlurViewController else {
            return
        }
        
        if segue.identifier == "Blurred1" {
            blurredViews.append(bubble)
            bubble.textLines = bubbleText1
//            let index = blurredViews.count - 1
//            blurredViews[index].numLines = NUMLINES1
//            blurredViews[index].textLines.append(BUBBLETEXT1)
//            blurredViews[index].textLines.append(BUBBLETEXT2)
//            blurredViews[index].textLines.append(BUBBLETEXT3)
            
        } else if segue.identifier == "Blurred2" {
            blurredViews.append(bubble)
            //let index = blurredViews.count - 1
            //blurredViews[index].buttons = buttons
            bubble.buttons = buttons
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBar()
        descriptionView.layer.cornerRadius = 12.0
        descriptionView.layer.masksToBounds = true

        let aaView = TileHolderView(numTiles: 6, tileWidth: 50, borderWidth: 3.0, blurriness: 0.5, shadowWidth: 2.5, isTheTitleHolder: true)
        //let zzzView = TileHolderView(numTiles: 3, tileWidth: 50, borderWidth: 3.0, blurriness: 0.0, shadowWidth: 2.5)
        
        titleViewHolder.addSubview(aaView)
    
        //titleViewHolder.addSubview(zzzView)
        
        aaView.center = CGPoint(x: titleViewHolder.center.x, y: 30)
        //zzzView.center = CGPoint(x: titleViewHolder.center.x + 50.0, y: 30)
        
        let a1 = Tile(frame: CGRect(x: 3.0, y: 3.0, width: 50, height: 50))
        let a2 = Tile(frame: CGRect(x: 56.0, y: 3.0, width: 50, height: 50))
        let z1 = Tile(frame: CGRect(x: 159.0, y: 3.0, width: 50, height: 50))
        let z2 = Tile(frame: CGRect(x: 212.0, y: 3.0, width: 50, height: 50))
        let z3 = Tile(frame: CGRect(x: 265.0, y: 3.0, width: 50, height: 50))
        
//        aaView.addSubview(a1)
//        aaView.addSubview(a2)
//        aaView.addSubview(z1)
//        aaView.addSubview(z2)
//        aaView.addSubview(z3)
        
        let attributes: [NSAttributedString.Key: Any] =  [.font: UIFont(name: "EuphemiaUCAS-Bold", size: 48.0)!,
                                                .foregroundColor: Colors.midBrown,
                                                .strokeWidth: -3.0 as AnyObject,
                                                .strokeColor: UIColor.black]


            
        // TODO: set the attributed title in Tile.swift instead
        let titleA = NSAttributedString(string: "A", attributes: attributes)
        let titleZ = NSAttributedString(string: "Z", attributes: attributes)
            
        a1.setAttributedTitle(titleA, for: UIControl.State())
        a2.setAttributedTitle(titleA, for: UIControl.State())
        z1.setAttributedTitle(titleZ, for: UIControl.State())
        z2.setAttributedTitle(titleZ, for: UIControl.State())
        z3.setAttributedTitle(titleZ, for: UIControl.State())
        
    }
    
    deinit {
        print("Home De-init")
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
