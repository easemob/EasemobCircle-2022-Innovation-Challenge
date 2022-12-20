//
//  ServerSearchResultViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/12/6.
//

import UIKit
import HyphenateChat

protocol ServerSearchResultViewControllerDelegate: AnyObject {
    
    func didSelect(_ server: EMCircleServer, at indexPath: IndexPath)
    func didSelect(_ channel: EMCircleChannel, at indexPath: IndexPath)
    
}

class ServerSearchResultViewController: ServerTableViewController {
    
    var searchResults: [SearchServerResult]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    weak var delegate: ServerSearchResultViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the responders
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.keyboardDismissMode = .onDrag

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        if let keyBoardSize = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardSize.height, right: 0)
            self.tableView.contentInset = contentInsets
        }
    }

    @objc func keyBoardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        searchResults?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sr = searchResults else {
            return 0
        }
        
        return sr[section].items().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sr = searchResults else {
            fatalError()
        }
        
        let item = sr[indexPath.section].items()[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier) as? SearchItemCell else {
            fatalError()
        }
        
        cell.configure(item)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let results = searchResults else {
            return nil
        }
        
        return results[section].sectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let sr = searchResults {
            let item = sr[indexPath.section].items()[indexPath.row]
            if let channel = item.channel {
                delegate?.didSelect(channel, at: indexPath)
            } else {
                guard let server = item.server else {
                    fatalError()
                }
                delegate?.didSelect(server, at: indexPath)
            }
        }
    }
}
