//
//  VoteEditViewController.swift
//  discord-ios
//
//  Created by xeskj on 2022/12/8.
//

import UIKit

class VoteEditViewController: UIViewController {
    @IBOutlet weak var deadlineButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var describeTextField: UITextField!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var optionsTableViewHeight: NSLayoutConstraint!
    
    //选项数量
    var optionsNumber = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "创建投票"
        self.optionsTableView.register(UINib.init(nibName: "VoteOptionsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "voteOptionsCell")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_black")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backBarButtonClick))
        // Do any additional setup after loading the view.
    }
    
    @objc func backBarButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addOptionClick(_ sender: Any) {
        if (optionsNumber >= 10) {
            return;
        }
        optionsNumber += 1
        optionsTableViewHeight.constant = CGFloat(optionsNumber*45)
        optionsTableView.reloadData()
    }
    
    //完成
    @IBAction func submit(_ sender: Any) {
    }
    
    //截止日期
    @IBAction func deadlineButtonClick(_ sender: Any) {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)

        DatePickerDialog().show("DatePickerDialog",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: threeMonthAgo,
                        maximumDate: currentDate,
                        datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.deadlineButton.setTitle(formatter.string(from: dt), for: .normal)
            }
        }
    }
    
    //时间选择器
    private lazy var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        
        return datePicker
    }()
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
