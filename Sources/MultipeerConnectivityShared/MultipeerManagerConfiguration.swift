//
//  MultipeerManagerConfiguration.swift
//  
//
//  Created by Miguel Costa on 05.07.23.
//

import Foundation
import MultipeerConnectivity
public struct MultipeerManagerConfiguration {
    let session: MCSession
    let advertiser: MCNearbyServiceAdvertiser
    let browser: MCNearbyServiceBrowser
    private let serviceType = "example-service"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)

    public init(session: MCSession,
                advertiser: MCNearbyServiceAdvertiser,
                browser: MCNearbyServiceBrowser) {
        self.session = session
        self.advertiser = advertiser
        self.browser = browser
    }

    public init() {
        self.session = MCSession(peer: myPeerID,
                                 securityIdentity: nil,
                                 encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                                    discoveryInfo: nil,
                                                    serviceType: serviceType)
        self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
    }
}
