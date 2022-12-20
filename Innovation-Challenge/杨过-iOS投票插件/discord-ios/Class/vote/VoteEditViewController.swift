//
//  VoteEditViewController.swift
//  discord-ios
//
//  Created by xeskj on 2022/12/8.
//

import UIKit

class VoteEditViewController: UIViewController {
    
    var optionsNumber = 2

    @IBOutlet weak var optionsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "创建投票"
        self.optionsTableView.register(UINib.init(nibName: "VoteOptionsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "voteOptionsCell")
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected okbject to the new view controller.
    }
    */

}

extension VoteEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsNumber;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "voteOptionsCell", for: indexPath) as? VoteOptionsTableViewCell
        if ((cell == nil)) {
            cell = Bundle.main.loadNibNamed("VoteOptionsTableViewCell", owner: self, options: nil)?.first as? VoteOptionsTableViewCell
        }
        
        return cell!
    }
    
    
}
