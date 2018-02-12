//
//  AtoZGestureRecognizerDelegate.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/12/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

class AtoZGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return true
        } else {
            return false
        }
    }
}
