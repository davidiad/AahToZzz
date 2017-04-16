//
//  GameCenterExtension.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/15/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import GameKit

extension UIViewController: GKGameCenterControllerDelegate {
    
    func saveHighScore(number: Int, levelNumber: Float) {
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "atozleaderboard")
            scoreReporter.value = Int64(number)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
            
            let levelReporter = GKScore(leaderboardIdentifier: "level_leaderboard")
            // Game Center only allows Int64, but with format with 1 decimal point, so multiply by 10
            levelReporter.value = Int64(levelNumber * 10)
            let levelArray: [GKScore] = [levelReporter]
            GKScore.reportScores(levelArray, withCompletionHandler: nil)
        }
    }
    
    public func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showLeaderboard() {
        let viewController = self//self.view.window?.rootViewController
        let gamecenterVC = GKGameCenterViewController()
        gamecenterVC.gameCenterDelegate = self
        viewController.presentViewController(gamecenterVC, animated: true, completion: nil)
        
    }
    
}
