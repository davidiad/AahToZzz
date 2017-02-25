//
//  Aah_to_ZzzTests.swift
//  Aah to ZzzTests
//
//  Created by David Fierstein on 2/14/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import XCTest
@testable import AahToZzz
import CoreData


class Aah_to_ZzzTests: XCTestCase {
    
    //var atozVC: AtoZViewController?
    
    
    var viewController: AtoZViewController!
    var model = AtoZModel.sharedInstance
    
    class MockDataProvider: NSObject {
        
        
        
        //var addPersonGotCalled = false
        
//        var managedObjectContext: NSManagedObjectContext?
//        weak var tableView: UITableView!
//        func addPerson(personInfo: PersonInfo) { addPersonGotCalled = true }
//        func fetch() { }
//        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
//        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//            return UITableViewCell()
//        }
        
    }

    
    
    /*
 func percentageFound() -> Int? {
 guard let numWordsPlayed = numWordsPlayed() else {
 return nil
 }
 guard let numWordsFound = numWordsFound() else {
 return nil
 }
 if numWordsPlayed > 0 {
 return Int(100.0 * Float(numWordsFound) / Float(numWordsPlayed))
 } else {
 return nil
 }
 }
 */
    func testCalculateInactiveQuota() {
        let p = model.calculateInactiveQuota(31)  //vc.percentage(50, 50)
        XCTAssert(p == 16)
    }
    
    func testPercentageFound() {
//        model.numWordsPlayed = 100
//        model.numWordsFound = 50
//        let p = model.percentageFound()
//        
//
//
//        XCTAssert(p == 50)
    }
 
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        //let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //atozVC = storyboard.instantiateInitialViewController() as? AtoZViewController
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
