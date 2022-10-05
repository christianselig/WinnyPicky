//
//  ViewController.swift
//  WinnyPicky
//
//  Created by Christian Selig on 2020-11-16.
//

import UIKit

class ViewController: UIViewController {
    let progressLabel = UILabel()
    let resultsLabel = UILabel()
    
    // Maps author/user ID to an array of comment IDs to prevent duplicates
    var commentsDatabase: [String: [String]] = [:]
    
    var startTime: CFAbsoluteTime!
    
    var logs: [String] = [] {
        didSet {
            let last10 = logs.suffix(10)
            let joined = last10.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.progressLabel.text = joined
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressLabel.textAlignment = .center
        progressLabel.backgroundColor = .systemTeal
        
        resultsLabel.backgroundColor = .systemOrange
        
        [progressLabel, resultsLabel].forEach { $0.font = UIFont.systemFont(ofSize: 13.0, weight: .regular); $0.numberOfLines = 0; view.addSubview($0) }
        
        // Don't let the screen sleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        decideWinner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        progressLabel.frame = view.bounds.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: view.bounds.height * 0.67, right: 0.0))
        resultsLabel.frame = view.bounds.inset(by: UIEdgeInsets(top: view.bounds.height * 0.33, left: 0.0, bottom: 0.0, right: 0.0))
    }

    func decideWinner() {
        // PushShift has a 100 item per request limit
        let fetchLimit: Int = 250
        
        let threadIDs: [String] = ["xtsjm6", "xu8zct"]
        startTime = CFAbsoluteTimeGetCurrent()
        let dispatchQueue = DispatchQueue(label: "WinnerQueue")
        var totalLoopsFinished = 0
        
        for (threadIndex, threadID) in threadIDs.enumerated() {
            DispatchQueue.global(qos: .background).async {
                var time: Int = 0
                
                var commentsForThreadID: Int = 0
                var loops: Int = 0
                
                while true {
                    let apiURL = URL(string: "https://api.pushshift.io/reddit/comment/search/?link_id=\(threadID)&limit=\(fetchLimit)&q=*&after=\(time)&fields=id,author,created_utc")!
                    
                    guard let data = try? Data(contentsOf: apiURL) else {
                        // Will retry
                        dispatchQueue.sync {
                            self.logs.append("Error fetching data for thread \(threadID), retrying")
                        }
                        
                        sleep(1)
                        continue
                    }
                    
                    let json = try! JSON(data: data)
                    let comments = json["data"].array!
                    
                    if comments.isEmpty {
                        // This is our exit from our infinite infinity (when PushShift returns no more results)
                        break
                    }
                    
                    for comment in comments {
                        let created = comment["created_utc"].int!
                        let author = comment["author"].string!.lowercased()
                        let commentID = comment["id"].string!
                        
                        dispatchQueue.sync {
                            if var existingComments = self.commentsDatabase[author] {
                                existingComments.append(commentID)
                                self.commentsDatabase[author] = existingComments
                            } else {
                                self.commentsDatabase[author] = [commentID]
                            }
                            
                            if comment == comments.last {
                                time = created
                            }
                        }
                    }
                    
                    commentsForThreadID += comments.count
                    loops += 1
                    
                    dispatchQueue.sync {
                        self.logs.append("\(comments.count) more from \(threadIndex), total: \(self.commentsDatabase.count) and \(commentsForThreadID) for thread. \(loops) loops.")
                    }
                    
                    // Avoid hitting the API too hard
                    sleep(1)
                }
                
                dispatchQueue.sync {
                    totalLoopsFinished += 1
                    
                    if totalLoopsFinished == threadIDs.count {
                        self.finishAndAnalyze()
                    }
                }
            }
        }
    }
    
    func finishAndAnalyze() {
        // Remove duplicate users
        var namesToRemove: [String] = []
        
        for (author, comments) in commentsDatabase {
            if comments.count > 1 {
                namesToRemove.append(author)
            }
        }
        
        let totalNamesRemoved = namesToRemove.count
        namesToRemove.forEach { commentsDatabase.removeValue(forKey: $0) }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        var resultsOutput: String = ""
        
        resultsOutput.append("🌶 FINISHED!\n")
        resultsOutput.append("Time elapsed: \(timeElapsed) s.\n")
        
        let totalComments = commentsDatabase.count
        resultsOutput.append("Total comments: \(totalComments)\n")
        
        resultsOutput.append("Total names removed: \(totalNamesRemoved)\n")
        
        let randomNumber = Int(arc4random_uniform(UInt32(totalComments)))
        resultsOutput.append("Random number is: \(randomNumber)\n")
        
        let allKeys = Array(commentsDatabase.keys)
        let winningUser = allKeys[randomNumber]
        
        resultsOutput.append("Winning user: \(winningUser)\n")
        resultsOutput.append("ID of winning comment: \(commentsDatabase[winningUser]!.first!)\n")
        
        DispatchQueue.main.async {
            self.resultsLabel.text = resultsOutput
        }
    }
}
