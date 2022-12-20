//
//  ChannelDetailTableViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/12/6.
//

import UIKit
import HyphenateChat
import SPAlert

class ChannelDetailTableViewController: UITableViewController {

    let server: EMCircleServer
    let channel: EMCircleChannel
    
    init(server: EMCircleServer, channel: EMCircleChannel) {
        self.server = server
        self.channel = channel
        super.init(style: .insetGrouped)
        
        title = "详情"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.setTitle("加入社区", for: .normal)
        
        let joinItem = UIBarButtonItem(title: "进入会话", style: .done, target: self, action: #selector(enterChat(_:)))
        navigationItem.rightBarButtonItem = joinItem
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc func enterChat(_ sender: UIBarButtonItem) {
        guard channel.isIn else {
            SPAlert.present(message: "请先加入频道", haptic: .warning)
            return
        }
        
        let vc = ChatViewController.newInstanceFromStoryboard(with: server, channel: channel)
        let pvc = navigationController?.presentingViewController
        dismiss(animated: true) {
            pvc?.show(vc, sender: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section < 2 ? 1 : channel.isIn ? (channel.members?.count ?? 0) : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "所属社群" : section == 2 && channel.isIn ? "频道成员" : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            if channel.isIn {
                guard let userId = channel.members?[indexPath.row].userId else {
                    fatalError()
                }
                let vc = ChatViewController.newInstanceFromStoryboard(with: userId)
                let pvc = navigationController?.presentingViewController
                dismiss(animated: true) {
                    pvc?.show(vc, sender: nil)
                }
            } else {
                // 加入channle 然后重新load members
                EMClient.shared().circleManager?.joinChannel(channel.serverId, channelId: channel.channelId, completion: { [weak self] _, err in
                    if err == nil {
                        Task {

                            self?.channel.isIn = true
                            await self?.channel.loadMembers()

                            DispatchQueue.main.async {
                                self?.tableView.reloadSections([indexPath.section], with: .automatic)
                            }
                        }
                    } else {
                        SPAlert.present(message: "加入频道失败", haptic: .error)
                    }
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        section == 0 ? channel.desc : nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.section {
            case 0:
                content.attributedText = NSAttributedString(string: "# \(channel.name)", attributes: [.foregroundColor: channel.custom!.color, .font : UIFont.systemFont(ofSize: 18)])
            case 1:
                content.text = server.name
                
                content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
                content.imageProperties.cornerRadius = 4.0
                
                guard let url = server.icon else { fatalError() }
                if url.starts(with: "http") {
                    content.image = UIImage(named: "logo")
                } else if url.contains("metro_logo") {
                    content.image = UIImage(named: "metro_logo_shanghai")
                } else if url.contains("beijing") {
                    content.image = UIImage(named: "metro_logo_beijing")
                }
            default:
                
            if (!channel.isIn) {
                
                content.textProperties.alignment = .center
                content.attributedText = NSAttributedString(string: "加入频道", attributes: [.foregroundColor: UIColor.systemBlue, .font : UIFont.boldSystemFont(ofSize: 18.0)])
                
            } else {
                guard let member = channel.members?[indexPath.row] else {
                    fatalError()
                }
                
                UserInfoManager.shared.fetchUserInfo(member.userId!) { userInfo in
                    DispatchQueue.main.async {
                        if let avatar = userInfo?.avatarUrl, let name = userInfo?.nickname {
                            let attr = NSMutableAttributedString(string: "\(avatar)  " + name, attributes: [.foregroundColor: UIColor.label])
                            
                            if (member.role == .owner) {
                                attr.append(NSAttributedString(string: " 所有者", attributes: [.foregroundColor: UIColor.secondary, .font: UIFont.systemFont(ofSize: 10)]))
                            }
                            
                            if member.role == .moderator {
                                attr.append(NSAttributedString(string: " 管理员", attributes: [.foregroundColor: UIColor.accent, .font: UIFont.systemFont(ofSize: 10)]))
                            }
                            
                            content.attributedText = attr
                        }
                                               
                        content.image = userInfo?.genderImage
                        content.imageProperties.maximumSize = CGSize(width: 18, height: 18)
                        
                        cell.accessoryType = .disclosureIndicator
                        cell.contentConfiguration = content
                        cell.setNeedsUpdateConfiguration()
                    }
                }
            }
        }
        
        cell.contentConfiguration = content

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
