//
//  ViewController.swift
//  Whiteboard
//
//  Created by Daniel Chiu on 2/23/15.
//  Copyright (c) 2015 Chiubaka Studios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  var lastPoint: CGPoint?
  @IBOutlet weak var canvas: UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    var touch = touches.anyObject() as UITouch
    lastPoint = touch.locationInView(view)
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    canvas?.frame = view.frame
    
    var touch = touches.anyObject() as UITouch
    var currentPoint = touch.locationInView(view)
    
    UIGraphicsBeginImageContext(view.frame.size)
    var context = UIGraphicsGetCurrentContext()
    canvas?.image?.drawInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
    CGContextMoveToPoint(context, lastPoint!.x, lastPoint!.y)
    CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y)
    CGContextSetLineCap(context, kCGLineCapRound)
    CGContextSetLineWidth(context, 10)
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
    CGContextSetBlendMode(context, kCGBlendModeNormal)
    
    CGContextStrokePath(context)
    canvas?.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    lastPoint = currentPoint
  }
}

