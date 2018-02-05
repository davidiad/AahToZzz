//
//  AtoZPopoverDelegate.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/5/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import Foundation
import UIKit

class AtoZPopoverDelegate: NSObject, UIPopoverPresentationControllerDelegate {
    // Presentation Delegate functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //return UIModalPresentationStyle.FullScreen
        // allows popever style on iPhone as opposed to Full Screen
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AtoZViewController.dismiss(first:)))
        navigationController.topViewController!.navigationItem.leftBarButtonItem = btnDone
        return navigationController
    }
    
    // added paramater 'first' only so #selector is recognized above - compiler can't disambiguate parameterless method
//    @objc func dismiss(first: Bool) {
////        self.dismiss(animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
//    }
    
    // Popover Delegate functions
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.left
    }
}
