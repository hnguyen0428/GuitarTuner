//
//  TuningView.swift
//  GuitarTuner
//
//  Created by Hoang on 12/29/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import UIKit


class TuningView: UIView {
    
    static let FREQ_RANGE: Float = 20.0
    
    var freqBar: FrequencyBar!
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    var centerMarker: TriangleView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupFreqBar()
        setupCenterMarker()
        setupLabels()
    }
    
    func setupFreqBar() {
        let width = self.frame.width
        let height = self.frame.height * 0.50
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        freqBar = FrequencyBar(frame: frame)
        freqBar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(freqBar)
        freqBar.widthAnchor.constraint(equalToConstant: width).isActive = true
        freqBar.heightAnchor.constraint(equalToConstant: height).isActive = true
        freqBar.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        freqBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func setupCenterMarker() {
        let width = self.frame.width * 0.05
        let height = width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        centerMarker = TriangleView(frame: frame, fillColor: .green)
        centerMarker.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(centerMarker)
        centerMarker.widthAnchor.constraint(equalToConstant: width).isActive = true
        centerMarker.heightAnchor.constraint(equalToConstant: height).isActive = true
        centerMarker.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        centerMarker.bottomAnchor.constraint(equalTo: freqBar.topAnchor, constant: 10.0).isActive = true
    }
    
    func setupLabels() {
        let width = self.frame.width * 0.20
        let height = self.frame.height * 0.25
        
        leftLabel = UILabel()
        rightLabel = UILabel()
        
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.text = "-\(Int(TuningView.FREQ_RANGE)) Hz"
        leftLabel.textColor = .white
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.text = "+\(Int(TuningView.FREQ_RANGE)) Hz"
        rightLabel.textColor = .white
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        leftLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        leftLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        leftLabel.centerXAnchor.constraint(equalTo: freqBar.leftAnchor).isActive = true
        leftLabel.bottomAnchor.constraint(equalTo: freqBar.topAnchor, constant: -5.0).isActive = true
        
        rightLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        rightLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        rightLabel.centerXAnchor.constraint(equalTo: freqBar.rightAnchor).isActive = true
        rightLabel.bottomAnchor.constraint(equalTo: freqBar.topAnchor, constant: -5.0).isActive = true
    }
    
    func moveCursor(actualFreq: Float, centerFreq: Float) {
        freqBar.moveCursor(actualFreq: actualFreq, centerFreq: centerFreq)
    }
    
    func resetCursor() {
        freqBar.resetCursor()
    }
    
    func turnGreen() {
        freqBar.turnGreen()
    }
    
    func resetColor() {
        freqBar.resetColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class FrequencyBar: UIView {
    
    var freqBar: UIView!
    var cursor: UIView!
    var cursorCenterXConstraint: NSLayoutConstraint!
    var initialPos: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFreqBar()
        setupCursor()
    }
    
    func setupFreqBar() {
        let height = self.frame.height * 0.90
        let width = self.frame.width * 0.99
        
        freqBar = UIView()
        freqBar.backgroundColor = .lightGray
        freqBar.alpha = 0.8
        freqBar.layer.cornerRadius = 10.0
        
        addSubview(freqBar)
        freqBar.translatesAutoresizingMaskIntoConstraints = false
        
        freqBar.widthAnchor.constraint(equalToConstant: width).isActive = true
        freqBar.heightAnchor.constraint(equalToConstant: height).isActive = true
        freqBar.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        freqBar.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func setupCursor() {
        let width: CGFloat = 2.0
        let height: CGFloat = self.frame.height
        
        cursor = UIView()
        cursor.backgroundColor = .black
        
        addSubview(cursor)
        cursor.translatesAutoresizingMaskIntoConstraints = false
        
        cursor.widthAnchor.constraint(equalToConstant: width).isActive = true
        cursor.heightAnchor.constraint(equalToConstant: height).isActive = true
        cursorCenterXConstraint = cursor.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        cursorCenterXConstraint.isActive = true
        initialPos = cursorCenterXConstraint.constant
        cursor.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func moveCursor(actualFreq: Float, centerFreq: Float) {
        let diff = actualFreq - centerFreq
        
        // Scale to the frequency bar
        let ratio = diff / TuningView.FREQ_RANGE
        let halfBarLength = freqBar.frame.width / 2
        
        var moveLength = halfBarLength * CGFloat(ratio)
        if ratio > 1.0 {
            moveLength = halfBarLength
        }
        else if ratio < -1.0 {
            moveLength = -halfBarLength
        }
        
        UIView.animate(withDuration: 1.0, animations: {
            self.cursorCenterXConstraint.constant = self.initialPos + moveLength
        })
    }
    
    func resetCursor() {
        UIView.animate(withDuration: 1.0, animations: {
            self.cursorCenterXConstraint.constant = self.initialPos
        })
    }
    
    func turnGreen() {
        freqBar.backgroundColor = .green
    }
    
    func resetColor() {
        freqBar.backgroundColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TriangleView: UIView {
    
    var fillColor: UIColor!
    
    init(frame: CGRect, fillColor: UIColor) {
        self.fillColor = fillColor
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        
        let rgba = fillColor.rgb()!
        
        context.setFillColor(red: rgba.r, green: rgba.g, blue: rgba.b,
                             alpha: rgba.a)
        context.fillPath()
    }
}
