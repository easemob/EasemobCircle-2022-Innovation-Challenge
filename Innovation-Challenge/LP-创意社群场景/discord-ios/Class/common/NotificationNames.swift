//
//  NotificationNames.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/14.
//

import Foundation

let EMCircleDidCreateServer = Notification.Name(rawValue: "EMCircleDidCreateServer")
let EMCircleDidUpdateServer = Notification.Name(rawValue: "EMCircleDidUpdateServer")
let EMCircleDidDestroyServer = Notification.Name(rawValue: "EMCircleDidDestroyServer")
let EMCircleDidJoinedServer = Notification.Name(rawValue: "EMCircleDidJoinedServer")
let EMCircleDidExitedServer = Notification.Name(rawValue: "EMCircleDidExitedServer")

let EMCircleDidCreateChannel = Notification.Name(rawValue: "EMCircleDidCreateChannel")
let EMCircleDidDestroyChannel = Notification.Name(rawValue: "EMCircleDidDestroyChannel")
let EMCircleDidUpdateChannel = Notification.Name(rawValue: "EMCircleDidUpdateChannel")
let EMCircleDidJoinChannel = Notification.Name(rawValue: "EMCircleDidJoinChannel")
let EMCircleDidExitedChannel = Notification.Name(rawValue: "EMCircleDidExitedChannel")

let EMThreadDidDestroy = Notification.Name(rawValue: "EMThreadDidDestroy")
let EMThreadDidExited = Notification.Name(rawValue: "EMThreadDidExited")

let EMCurrentUserInfoUpdate = Notification.Name(rawValue: "EMCurrentUserInfoUpdate")
let EMUserInfoUpdate = Notification.Name(rawValue: "EMUserInfoUpdate")

let EMMessageUnreadCountChange = Notification.Name(rawValue: "EMMessageUnreadCountChange")

let MainShouldSelectedServer = Notification.Name(rawValue: "MainShouldSelectedServer")
