//
//  TuningView.swift
//  GuitarTuner
//
//  Created by Hoang on 12/27/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import Foundation
import UIKit

class TuningView: UIView {
    
    static let BUTTON_WIDTH: CGFloat = 0.20
    
    var sixth: UIButton!
    var fifth: UIButton!
    var fourth: UIButton!
    var third: UIButton!
    var second: UIButton!
    var first: UIButton!
    var pegs: [UIButton] = [UIButton]()
    
    init(frame: CGRect, tuningType: String) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let buttonWidth = frame.width * TuningView.BUTTON_WIDTH
        let buttonHeight = buttonWidth * 0.85
        
        
        sixth = UIButton()
        sixth.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sixth)
        sixth.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        sixth.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        sixth.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sixth.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        fifth = UIButton()
        fifth.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fifth)
        fifth.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        fifth.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        fifth.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        fifth.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        

        fourth = UIButton()
        fourth.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fourth)
        fourth.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        fourth.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        fourth.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        fourth.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        
        third = UIButton()
        third.translatesAutoresizingMaskIntoConstraints = false
        addSubview(third)
        third.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        third.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        third.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        third.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        
        second = UIButton()
        second.translatesAutoresizingMaskIntoConstraints = false
        addSubview(second)
        second.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        second.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        second.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        second.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        first = UIButton()
        first.translatesAutoresizingMaskIntoConstraints = false
        addSubview(first)
        first.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        first.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        first.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        first.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        pegs.append(sixth)
        pegs.append(fifth)
        pegs.append(fourth)
        pegs.append(third)
        pegs.append(second)
        pegs.append(first)
        
        for button in pegs {
            button.layer.borderWidth = 1
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.backgroundColor = .darkGray
        }
        
        var i = 0
        for char in tuningType {
            pegs[i].setTitle(String(char), for: .normal)
            i += 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
