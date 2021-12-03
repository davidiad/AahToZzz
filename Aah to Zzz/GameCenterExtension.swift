//
//  GameCenterExtension.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/15/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import GameKit

extension UIViewController: GKGameCenterControllerDelegate {
    
    func reportScores(_ levelNumber: Float, percentage: Float, numberOfLists: Int, numberOfWords: Int) {
        if GKLocalPlayer.local.isAuthenticated {
//            let scoreReporter = GKScore(leaderboardIdentifier: "atozleaderboard")
//            scoreReporter.value = Int64(number)
//            let scoreArray: [GKScore] = [scoreReporter]
//            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
            
            let levelReporter = GKScore(leaderboardIdentifier: "level_leaderboard")
            // Game Center only allows Int64, but with format with 1 decimal point, so multiply by 10
            levelReporter.value = Int64(levelNumber * 10)
            let levelArray: [GKScore] = [levelReporter]
            GKScore.report(levelArray, withCompletionHandler: nil)
            
            let percentageReporter = GKScore(leaderboardIdentifier: "percentage")
            // Game Center only allows Int64, but with format with 1 decimal point, so multiply by 10
            percentageReporter.value = Int64(percentage * 10)
            let percentageArray: [GKScore] = [percentageReporter]
            GKScore.report(percentageArray, withCompletionHandler: nil)
            
            let numListsReporter = GKScore(leaderboardIdentifier: "numberOfLists")
            numListsReporter.value = Int64(numberOfLists)
            let numberOfListsArray: [GKScore] = [numListsReporter]
            GKScore.report(numberOfListsArray, withCompletionHandler: nil)
            
            let numWordsFoundReporter = GKScore(leaderboardIdentifier: "numberOfWordsFound")
            numWordsFoundReporter.value = Int64(numberOfWords)
            let numberOfWordsArray: [GKScore] = [numWordsFoundReporter]
            GKScore.report(numberOfWordsArray, withCompletionHandler: nil)
        }
    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func showLeaderboard() {
        let viewController = self//self.view.window?.rootViewController
        let gamecenterVC = GKGameCenterViewController()
        gamecenterVC.gameCenterDelegate = self
        viewController.present(gamecenterVC, animated: true, completion: nil)
        
    }
    
}
