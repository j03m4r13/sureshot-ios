//
//  TimedShotPopupViewController.swift
//  OpenCVSample_iOS
//
//  Created by Joemarie Aliling on 3/27/23.
//  Copyright © 2023 Hiroki Ishiura. All rights reserved.
//

import UIKit
import Foundation

class ResultsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataSourceArray = ["Item 1", "Item 2", "Item 3"]
    var timeRecordsData: [Double]?
    var timeIndex: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        timeIndex = 0
        if let parameterValue = timeRecordsData {
                print("Parameter value is: \(parameterValue)")
            }
        // Assuming you have an array of strings that represents the data source for the table view
    }
   


}
extension ResultsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeRecordsData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if (self.timeIndex < timeRecordsData?.count ?? 10) {
            cell.textLabel?.text = String(format: "%0.2f", timeRecordsData?[self.timeIndex] ?? 0.0)
        }
        self.timeIndex = self.timeIndex + 1
        
        return cell
    }
}

