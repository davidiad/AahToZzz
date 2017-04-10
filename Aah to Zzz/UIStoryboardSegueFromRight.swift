//
//  UIStoryboardSegueFromRight.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/7/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//  based on code from Marc Boeren
//  https://gist.github.com/marcboeren/165ed7de30178acfdad4
//  DF added a segue from the other direction (left)
//  and added a slide of the source over as the destination slides in
//  TODO: make sure not setting up a strong-strong retain cycle

import UIKit

class UIStoryboardSegueFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        // The position of the destination view before animation.
        dst.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.5,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    // The new position of the destination view
                                    dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
                                    // slide the source view over as the destination slides in
                                    src.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
            },
                                   completion: { finished in
                                    src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
    
    deinit {
        print("DEINIT RUGHT")
    }
}

class UIStoryboardSegueFromLeft: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        // Make the position negative, has it come in from the left instead of the right
        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.5,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
                                    // slide the source view over as the destination slides in
                                    src.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)
            },
                                   completion: { finished in
                                    src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
    
    deinit {
        print("DEINIT Left")
    }
}

/* // Unwind Segue
class UIStoryboardUnwindSegueFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)
        src.view.transform = CGAffineTransformMakeTranslation(0, 0)
        
        UIView.animateWithDuration(0.25,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    src.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)
            },
                                   completion: { finished in
                                    src.dismissViewControllerAnimated(false, completion: nil)
            }
        )
    }
} */
