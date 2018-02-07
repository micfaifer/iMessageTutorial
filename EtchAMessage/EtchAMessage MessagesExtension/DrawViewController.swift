//
//  DrawViewController.swift
//  EtchAMessage MessagesExtension
//
//  Created by Piera Marchesini on 05/02/18.
//  Copyright © 2018 Piera Marchesini. All rights reserved.
//

import UIKit

protocol SendMessage {
    func didSendDraw(on image: UIImage)
    func didSendAlgumaCoisa(text: String)
}

class DrawViewController: UIViewController {
    
    @IBOutlet weak var magicScreen: UIView!
    
    var previousPoint = CGPoint(x: 0, y: 0)
    var currentDirection = ""
    var beganPoint: CGPoint?
    var timerX: Timer?
    var timerY: Timer?
    
    public var delegate: SendMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        // Do any additional setup after loading the view.
        previousPoint.y = self.magicScreen.frame.size.height+48
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Shake Methods
    // We are willing to become first responder to get shake motion
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Why are you shaking me?")
            //Apaga o desenho
            for view in self.magicScreen.subviews {
                view.removeFromSuperview()
            }
        }
        if event?.subtype == UIEventSubtype.motionShake {
            print("You shook me, now what")
        }
    }
    
    
    
    @IBAction func handlePanX(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            beganPoint = recognizer.translation(in: self.view)
        case .changed:
            guard let began = beganPoint else { return }
            if (abs(began.x - recognizer.translation(in: self.view).x) <= 30) {
                return
            } else if began.x < recognizer.translation(in: self.view).x {
                self.currentDirection = "right"
                //START TIMER
                self.startTimerX()
            } else {
                self.currentDirection = "left"
                //START TIMER
                self.startTimerX()
            }
        case .ended:
            self.stopTimerX()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        default:
            return
        }
    }

    @IBAction func handlePanY(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            beganPoint = recognizer.translation(in: self.view)
        case .changed:
            guard let began = beganPoint else { return }
            if (abs(began.y - recognizer.translation(in: self.view).y) <= 30) {
                return
            } else if began.y < recognizer.translation(in: self.view).y {
                self.currentDirection = "up"
                //START TIMER
                self.startTimerY()
            } else {
                self.currentDirection = "down"
                //START TIMER
                self.startTimerY()
            }
        case .ended:
            self.stopTimerY()
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        default:
            return
        }
    }
    
    @objc
    func drawXLine(){
        let path = UIBezierPath()
        path.move(to: previousPoint)
        if currentDirection == "right"{
            //Máximo da tela
            if previousPoint.x >= self.magicScreen.frame.size.width-3 {
                return
            }
            path.addLine(to: CGPoint(x: previousPoint.x+5, y: previousPoint.y))
            previousPoint.x += 5
        } else if currentDirection == "left" {
            //Mínimo da tela
            if previousPoint.x <= 0 {
                return
            }
            path.addLine(to: CGPoint(x: previousPoint.x-5, y: previousPoint.y))
            previousPoint.x -= 5
        }
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 2
        layer.path = path.cgPath
        DispatchQueue.main.async {
            self.magicScreen.layer.addSublayer(layer)
        }
    }
    
    @objc
    func drawYLine(){
        let path = UIBezierPath()
        path.move(to: previousPoint)
        if currentDirection == "up"{
            //Máximo da tela
            if previousPoint.y >= self.magicScreen.frame.size.height-2 {
                return
            }
            path.addLine(to: CGPoint(x: previousPoint.x, y: previousPoint.y+5))
            previousPoint.y += 5
        } else if currentDirection == "down" {
            //Mínimo da tela
            if previousPoint.y <= 2 {
                return
            }
            path.addLine(to: CGPoint(x: previousPoint.x, y: previousPoint.y-5))
            previousPoint.y -= 5
        }
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 2
        layer.path = path.cgPath
        DispatchQueue.main.async {
            self.magicScreen.layer.addSublayer(layer)
        }
    }
    
    //MARK: - Timer
    func startTimerX(){
        if self.timerX == nil {
            self.timerX = Timer.scheduledTimer(timeInterval: 0.014, target: self, selector: #selector(DrawViewController.drawXLine), userInfo: nil, repeats: true)
            self.timerX?.fire()
        }
    }
    
    func stopTimerX(){
        self.timerX?.invalidate()
        self.timerX = nil
    }
    
    func startTimerY(){
        if self.timerY == nil {
            self.timerY = Timer.scheduledTimer(timeInterval: 0.014, target: self, selector: #selector(DrawViewController.drawYLine), userInfo: nil, repeats: true)
            self.timerY?.fire()
        }
    }
    
    func stopTimerY(){
        self.timerY?.invalidate()
        self.timerY = nil
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let newImage = UIImage(view: self.magicScreen)
       self.delegate?.didSendDraw(on: newImage)
    }
    
}
