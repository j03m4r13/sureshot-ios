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
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parameterValue = timeRecordsData {
                print("Parameter value is: \(parameterValue)")
            }
        // Assuming you have an array of strings that represents the data source for the table view
    }
   


}
extension ResultsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 19
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Joe \(indexPath)" 
        return cell
    }
}

