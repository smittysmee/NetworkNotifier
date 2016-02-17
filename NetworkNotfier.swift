//
//  NetworkNotifier.swift
//  E-App
//
//  Created by Alex Smith on 2/17/16.
//  Copyright © 2016 Alex Smith. All rights reserved.
//  See LICENSE for licensing information
//

import Foundation

class NetworkNotifier:NSObject{
    
    let kNetworkNotifierNotification = "kNetworkNotifierNotificationKey"
    
    var remoteHostName:String!
    
    private var _currentStatus:NetworkStatus!
    var currentStatus:NetworkStatus!{
        get{
            return _currentStatus
        }set(newStatus){
            /* Check if it is the same status as previous */
            if newStatus == _currentStatus{
                return
            }
            
            /* The status is not the same */
            _currentStatus = newStatus
            
            /* Post notifications */
            networkStatusChanged()
        }
    }
    
    private var notifierEnabled:Bool = false
    private var reachables:[Reachability]!
    
    init(withHost host:String) {
        /* Call the super */
        super.init()
        
        /* Initialize the array */
        reachables = [Reachability]()
        remoteHostName = host
        
        /* Setup Notifiers */
        setupNotifiers()
    }
    
    deinit {
        /* Remove the notifiers */
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func startNotifier(){
        notifierEnabled = true
    }
    
    func stopNotifier(){
        notifierEnabled = false
    }
    
    func setupNotifiers(){
        /* Create the notifcations for reachability */
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        /* Remote Host */
        let hostReachability:Reachability = Reachability(hostName: remoteHostName)
        hostReachability.startNotifier()
        reachables.append(hostReachability)
        
//        /* Internet Connection */
//        let internetReachability:Reachability = Reachability.reachabilityForInternetConnection()
//        internetReachability.startNotifier()
//        reachables.append(internetReachability)
//
//        /* Wifi */
//        let wifiReachability = Reachability.reachabilityForLocalWiFi()
//        wifiReachability.startNotifier()
//        reachables.append(wifiReachability)
    }
    
    func reachabilityChanged(notification: NSNotification) {
        /* Grab the reachability object */
        if let reachability = notification.object as? Reachability{
            /* Perform updates on the UI */
            let networkStatus = reachability.currentReachabilityStatus()
            
            /* Set the newtwork Status */
            currentStatus = networkStatus
        }
    }
    
    func networkStatusChanged(){
        /* Ensure that have the notification post enabled */
        if !notifierEnabled{
            return
        }
        
        /* Update the status */
        switch(currentStatus){
        case NotReachable:
            print("not reachable")
            break
        case ReachableViaWiFi:
            print("wifi")
            break
        case ReachableViaWWAN:
            print("wan")
            break
        default:
            break
        }
        
        /* Create the user dictionary */
        let userInfo:Dictionary<String, AnyObject> = [
            "networkStatus": currentStatus.rawValue
        ]
        
        /* Post the notification */
        NSNotificationCenter.defaultCenter().postNotificationName(kNetworkNotifierNotification, object: nil, userInfo: userInfo)
    }
}
