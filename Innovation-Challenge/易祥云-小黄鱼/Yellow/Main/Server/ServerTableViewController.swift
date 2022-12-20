//
//  ServerTableViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/12/6.
//

import UIKit
import HyphenateChat
import SPAlert

class ServerTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tableView == nil {
            let tb = UITableView(frame: view.bounds)
            view.addSubview(tb)
            tableView = tb
            
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "CircleChannelCell", bundle: nil), forCellReuseIdentifier: CircleChannelCell.identifier)
        tableView.register(UINib(nibName: "CircleDefaultChannelCell", bundle: nil), forCellReuseIdentifier: CircleDefaultChannelCell.identifier)
    }
}

