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
    
    @IBAction func playGame(sender: AnyObject) {
       // performSegueWithIdentifier("PlaySegue", sender:self)
    }
    

    @IBOutlet weak var rightSideBar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBar()
        descriptionView.layer.cornerRadius = 12.0
        descriptionView.layer.masksToBounds = true
        buttonHolderView.layer.cornerRadius = 12.0
        buttonHolderView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: repeated in Progress VC. Consolidate.
    func addGradientBar() {
        let gradient = model.yellowPinkBlueGreenGradient()
        //gradient.frame = rightSideBar.frame
        //gradient.frame = CGRectMake(rightSideBar.frame.origin.x, rightSideBar.frame.origin.y, 60, view.bounds.height)
        gradient.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height)
        rightSideBar.layer.addSublayer(gradient) 
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
