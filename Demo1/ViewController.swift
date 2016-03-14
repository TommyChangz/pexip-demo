//
//  ViewController.swift
//  Demo1
//
//  Created by Ian Mortimer on 14/10/2015.
//  Copyright © 2015 Ian Mortimer. All rights reserved.
//

import UIKit
import PexKit

class ViewController: UIViewController, UITableViewDataSource, ConferenceDelegate {

    // user interface
    @IBOutlet var addressBar: UITextField!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var videoView: PexVideoView!
    @IBOutlet var endConference: UIButton!
    @IBOutlet var rosterTableView: UITableView!
    @IBOutlet var microphoneSwitch: UISwitch!
    @IBOutlet var startActivityIndicator: UIActivityIndicatorView!
    
    
    // conference elements
    var conference: Conference?
    var rosterList: [Participant] = []
    var mobileParticipant: Participant?
    
    // demo application settings
    let mobileParticipantDemoName = "Demoapp"
    let conferenceDemoRoomName = "dervis.acando@pexipdemo.com"
    let conferenceDemoRoomPin = "12345"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        addressBar.text = conferenceDemoRoomName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func me() -> Participant? {
        return self.rosterList.filter({ p in
            p.UUID!.toString() == self.conference?.UUID!.toString()
        }).first
    }
    
    func rosterUpdate(rosterList: [Participant]) {
        self.rosterList = rosterList
        self.rosterTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.rosterTableView.dequeueReusableCellWithIdentifier("RosterCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.rosterList[indexPath.row].displayName
        cell.detailTextLabel?.text = self.rosterList[indexPath.row].uri
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rosterList.count
    }

    @IBAction func joinAction(sender: UIButton) {

        guard let uri = ConferenceURI(uri: addressBar.text!) else {
            print("Feil konferanse uri. Avslutter.")
            return
        }
        
        self.startActivityIndicator.startAnimating()
        
        let newConference = Conference()
        print("Laget en konferanse.")
        
        self.registerEventHandling(newConference)
        
        newConference.connect(mobileParticipantDemoName, URI: uri, pin: conferenceDemoRoomPin) { ok in
            if (!ok) {
                print("Koblet ikke til.")
                return
            }
            
            self.connectToConference(newConference)
        }
    }
    
    func registerEventHandling(conference:  Conference)  {
        conference.delegate = self
        conference.listenForEvents(failonerror: true)
    }
    
    func connectToConference(conference:  Conference) {
        print("Henter token.")
        conference.requestToken { status in
            self.listenForEventsAndEscalate(conference)
        }
    }
    
    func listenForEventsAndEscalate(conference: Conference) {
        // start listening for events
        conference.listenForEvents(failonerror: true)
        
        // Set videoView property to point to a PexVideoView
        conference.videoView = self.videoView
        
        conference.escalateMedia { status in
            print("Media escalation status was \(status)")
            self.conference = conference
            self.startActivityIndicator.stopAnimating()
        }
    }
    
    @IBAction func endCurrentCall(sender: UIButton) {
        self.conference?.releaseToken({
            _ in print("Fjerner token.")
            self.conference?.disconnectMedia({_ in print("Lukker video.")})
            self.conference?.videoView?.renderFrame(nil)
            self.conference?.videoView?.renderFrame(nil)
        
            // remove the mobile from the roster table
            if let me = self.me() {
                self.rosterList = self.rosterList.filter({ p in
                    p.UUID?.toString() != me.UUID?.toString()
                })
                self.rosterUpdate(self.rosterList)
            }
            
        })
    }
    
    @IBAction func toggleMicrophoneSwitch(sender: UISwitch) {
        if let me = me() {
            if microphoneSwitch.on {
                self.conference?.unmuteParticipant(me, completion:{_ in print("Skrudd på mikrofonen.")})
            } else {
                self.conference?.muteParticipant(me, completion:{_ in print("Skrudd av mikrofonen.")})
            }
        }
    }
    

}

