//
//  Queue.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/18/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import Foundation
//TODO:-remove this file if not using
public struct Queue<T> {
//    fileprivate var array = [T?]()
//    fileprivate var head = 0
    
    var array = [T?]()
    var head = 0
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var count: Int {
        return array.count - head
    }
    
    public mutating func enqueue(element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        
        array[head] = nil
        head += 1
        
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        
        return element
    }
    
    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
}
