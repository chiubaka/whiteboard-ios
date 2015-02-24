//
//  ViewController.swift
//  Whiteboard
//
//  Created by Daniel Chiu on 2/23/15.
//  Copyright (c) 2015 Chiubaka Studios. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
  let serviceType = "Whiteboard"
  
  var lastPoint: CGPoint?
  @IBOutlet weak var canvas: UIImageView?
  var peerID: MCPeerID!
  var session: MCSession!
  var browser: MCBrowserViewController!
  var assistant: MCAdvertiserAssistant!
  var browserPresented = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    session = MCSession(peer: peerID)
    session.delegate = self;
        
    browser = MCBrowserViewController(serviceType: serviceType, session: session)
    browser.delegate = self
    
    assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
    
    assistant.start()
  }
  
  override func viewDidAppear(animated: Bool) {
    if (!browserPresented) {
      presentViewController(browser, animated: true, completion: nil)
      browserPresented = true
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    var touch = touches.anyObject() as UITouch
    lastPoint = touch.locationInView(view)
  }
  
  func drawLine(start: CGPoint, end: CGPoint) {
    UIGraphicsBeginImageContext(view.frame.size)
    var context = UIGraphicsGetCurrentContext()
    canvas?.image?.drawInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
    CGContextMoveToPoint(context, start.x, start.y)
    CGContextAddLineToPoint(context, end.x, end.y)
    CGContextSetLineCap(context, kCGLineCapRound)
    CGContextSetLineWidth(context, 10)
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
    CGContextSetBlendMode(context, kCGBlendModeNormal)
    
    CGContextStrokePath(context)
    canvas?.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    canvas?.frame = view.frame
    
    var touch = touches.anyObject() as UITouch
    var currentPoint = touch.locationInView(view)
    
    drawLine(lastPoint!, end: currentPoint)
    var error: NSError?
    
    var data = NSKeyedArchiver.archivedDataWithRootObject([lastPoint!.x, lastPoint!.y, currentPoint.x, currentPoint.y])
    
    session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
    
    if (error != nil) {
      print("Error sending data: \(error?.localizedDescription)")
    }
    
    lastPoint = currentPoint
  }
  
  func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    var coordinates: [CGFloat] = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [CGFloat]
    
    dispatch_async(dispatch_get_main_queue()) {
      self.drawLine(CGPointMake(coordinates[0], coordinates[1]), end: CGPointMake(coordinates[2], coordinates[3]))
    }
  }
  
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    
  }
  
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    
  }

  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    
  }
  
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    
  }
}

