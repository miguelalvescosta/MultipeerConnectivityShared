//
//  File.swift
//
//
//  Created by Miguel Costa on 04.07.23.
//

import Foundation
import MultipeerConnectivity


public protocol MultipeerManagerDelegate: AnyObject {
    func didReceive(person: Person)
    func didChangeConnectionStatus(connected: Bool)
}

public class MultipeerManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    private let serviceType = "example-service"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    public weak var delegate: MultipeerManagerDelegate?

    public override init() {
        super.init()
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        assignDelegates()

    }

    public init(session: MCSession, advertiser: MCNearbyServiceAdvertiser, browser: MCNearbyServiceBrowser) {
           self.session = session
           self.advertiser = advertiser
           self.browser = browser
           super.init()
           assignDelegates()
       }

    private func assignDelegates() {
        session?.delegate = self
        advertiser?.delegate = self
        browser?.delegate = self
    }

    public func startAdvertising() {
        advertiser?.startAdvertisingPeer()
    }

    public func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
    }

    public func startBrowsing() {
        browser?.startBrowsingForPeers()
    }

    public func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }

    public func send(person: Person) {
        guard let session = session else { return }
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(person)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data: \(error.localizedDescription)")
        }
    }

    // MARK: - MCSessionDelegate

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.didChangeConnectionStatus(connected: true)
        case .notConnected:
            delegate?.didChangeConnectionStatus(connected: false)
        @unknown default:
            break
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let person = try JSONDecoder().decode(Person.self, from: data)
            delegate?.didReceive(person: person)
        } catch {
            print("Error receiving data: \(error.localizedDescription)")
        }
    }

    // MARK: - MCNearbyServiceAdvertiserDelegate

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                           withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }

    // MARK: - MCNearbyServiceBrowserDelegate

    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}
