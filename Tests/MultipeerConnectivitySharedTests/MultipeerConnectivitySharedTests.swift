import XCTest
import MultipeerConnectivity
@testable import MultipeerConnectivityShared

class MultipeerConnectivitySharedTests: XCTestCase {
    var sessionMock: MCSessionMock!
    var advertiserMock: MCNearbyServiceAdvertiserMock!
    var browserMock: MCNearbyServiceBrowserMock!
    var multipeerManager: MultipeerManager!
    var delegateMock: MultipeerManagerDelegateMock!
    var multipeerManagerMockConfiguration: MultipeerManagerConfiguration!

    override func setUp() {
        super.setUp()
        sessionMock = MCSessionMock(peer: MCPeerID(displayName: UIDevice.current.name))
        advertiserMock = MCNearbyServiceAdvertiserMock(peer: MCPeerID(displayName: UIDevice.current.name), discoveryInfo: nil, serviceType: "example-service")
        browserMock = MCNearbyServiceBrowserMock(peer: MCPeerID(displayName: UIDevice.current.name), serviceType: "example-service")
        delegateMock = MultipeerManagerDelegateMock()
        multipeerManagerMockConfiguration = MultipeerManagerConfiguration(session: sessionMock, advertiser: advertiserMock, browser: browserMock)
        multipeerManager = MultipeerManager(config: multipeerManagerMockConfiguration)
        multipeerManager.delegate = delegateMock
    }

    override func tearDown() {
        sessionMock = nil
        advertiserMock = nil
        browserMock = nil
        multipeerManager = nil
        super.tearDown()
    }

    func testStartAdvertising() {
        multipeerManager.startAdvertising()
        XCTAssertTrue(advertiserMock.startAdvertisingPeerCalled)
    }

    func testStopAdvertising() {
        multipeerManager.stopAdvertising()
        XCTAssertTrue(advertiserMock.stopAdvertisingPeerCalled)
    }

    func testDidReceivePerson() {
        let person = Person(name: "Jane Smith", age: 25)
        let personData = try! JSONEncoder().encode(person)
        let multipeerManager = MultipeerManager(config: multipeerManagerMockConfiguration)
        let delegateMock = MultipeerManagerDelegateMock()
        multipeerManager.delegate = delegateMock

        multipeerManager.session(sessionMock, didReceive: personData, fromPeer: MCPeerID(displayName: "Sender"))

        XCTAssertTrue(delegateMock.didReceivePersonCalled)
        XCTAssertEqual(delegateMock.receivedPerson, person)
    }

    func testDidChangeConnectionStatusConnected() {
        let multipeerManager = MultipeerManager(config: multipeerManagerMockConfiguration)
        let delegateMock = MultipeerManagerDelegateMock()
        multipeerManager.delegate = delegateMock

        multipeerManager.session(sessionMock, peer: MCPeerID(displayName: "Peer"), didChange: .connected)

        XCTAssertTrue(delegateMock.didChangeConnectionStatusCalled)
        XCTAssertTrue(delegateMock.connectedStatus ?? false)
    }

}


class MCSessionMock: MCSession {
    var sendCalled = false
    var receivedData: Data?

    init(peer: MCPeerID) {
        super.init(peer: peer, securityIdentity: nil, encryptionPreference: .required)
    }

    override func send(_ data: Data, toPeers peerIDs: [MCPeerID], with mode: MCSessionSendDataMode) throws {
        sendCalled = true
        receivedData = data
        try super.send(data, toPeers: peerIDs, with: mode)
    }


}


class MCNearbyServiceAdvertiserMock: MCNearbyServiceAdvertiser {
    var startAdvertisingPeerCalled = false
    var stopAdvertisingPeerCalled = false

    override init(peer: MCPeerID, discoveryInfo: [String: String]?, serviceType: String) {
        super.init(peer: peer, discoveryInfo: discoveryInfo, serviceType: serviceType)
    }

    override func startAdvertisingPeer() {
        startAdvertisingPeerCalled = true
    }

    override func stopAdvertisingPeer() {
        stopAdvertisingPeerCalled = true
    }
}


class MCNearbyServiceBrowserMock: MCNearbyServiceBrowser {
    var invitePeerCalled = false
    var invitedPeerID: MCPeerID?

    override init(peer: MCPeerID, serviceType: String) {
        super.init(peer: peer, serviceType: serviceType)
    }

    override func invitePeer(_ peerID: MCPeerID, to session: MCSession, withContext context: Data?, timeout: TimeInterval) {
        invitePeerCalled = true
        invitedPeerID = peerID
    }

}
class MultipeerManagerDelegateMock: MultipeerManagerDelegate {
    var didReceivePersonCalled = false
    var receivedPerson: Person?
    var didChangeConnectionStatusCalled = false
    var connectedStatus: Bool?

    func didReceive(person: Person) {
        didReceivePersonCalled = true
        receivedPerson = person
    }

    func didChangeConnectionStatus(connected: Bool) {
        didChangeConnectionStatusCalled = true
        connectedStatus = connected
    }
}
