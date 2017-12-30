//
//  TuningView.swift
//  GuitarTuner
//
//  Created by Hoang on 12/29/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import UIKit


class TuningView: UIView {
    
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
        leftLabel.text = "-20 Hz"
        leftLabel.textColor = .white
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.text = "+20 Hz"
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class FrequencyBar: UIView {
    
    var freqBar: UIView!
    var cursor: UIView!
    var cursorCenterConstraint: NSLayoutConstraint!
    
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
        cursorCenterConstraint = cursor.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        cursorCenterConstraint.isActive = true
        cursor.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
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
