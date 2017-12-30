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
    
    static let BUTTON_WIDTH: CGFloat = 0.25
    static let BUTTON_BORDER_R: CGFloat = 20.0
    
    var sixth: UIButton!
    var fifth: UIButton!
    var fourth: UIButton!
    var third: UIButton!
    var second: UIButton!
    var first: UIButton!
    var pegs: [UIButton] = [UIButton]()
    
    var chosenString: Int = 0
    weak var delegate: TuningViewDelegate?
    
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
            button.layer.cornerRadius = TuningView.BUTTON_BORDER_R
            button.backgroundColor = .darkGray
            button.addTarget(self, action: #selector(setSelected), for: .touchUpInside)
        }
        
        var i = 0
        var j = 0
        while i < tuningType.count {
            let index = tuningType.index(tuningType.startIndex, offsetBy: i)
            
            if i == tuningType.count - 1 {
                pegs[j].setTitle(String(tuningType[index]), for: .normal)
                break
            }
            
            let nextIndex = tuningType.index(tuningType.startIndex, offsetBy: i+1)
            
            if String(tuningType[nextIndex]) == "#" {
                let note = String(tuningType[index]) + String(tuningType[nextIndex])
                pegs[j].setTitle(note, for: .normal)
                i += 2
            }
            else {
                let note = tuningType[index]
                pegs[j].setTitle(String(note), for: .normal)
                i += 1
            }
            
            j += 1
        }
    }
    
    @objc func setSelected(_ button: UIButton) {
        switch button {
        case first:
            setStringChosen(num: 1)
        case second:
            setStringChosen(num: 2)
        case third:
            setStringChosen(num: 3)
        case fourth:
            setStringChosen(num: 4)
        case fifth:
            setStringChosen(num: 5)
        case sixth:
            setStringChosen(num: 6)
        default:
            break
        }
    }
    
    func setStringChosen(num: Int) {
        setAllUnchosen()
        var selectedStr: String?
        
        switch num {
        case 1:
            first.backgroundColor = .white
            first.layer.borderColor = UIColor.black.cgColor
            first.setTitleColor(.black, for: .normal)
            selectedStr = first.titleLabel?.text
        case 2:
            second.backgroundColor = .white
            second.layer.borderColor = UIColor.black.cgColor
            second.setTitleColor(.black, for: .normal)
            selectedStr = second.titleLabel?.text
        case 3:
            third.backgroundColor = .white
            third.layer.borderColor = UIColor.black.cgColor
            third.setTitleColor(.black, for: .normal)
            selectedStr = third.titleLabel?.text
        case 4:
            fourth.backgroundColor = .white
            fourth.layer.borderColor = UIColor.black.cgColor
            fourth.setTitleColor(.black, for: .normal)
            selectedStr = fourth.titleLabel?.text
        case 5:
            fifth.backgroundColor = .white
            fifth.layer.borderColor = UIColor.black.cgColor
            fifth.setTitleColor(.black, for: .normal)
            selectedStr = fifth.titleLabel?.text
        case 6:
            sixth.backgroundColor = .white
            sixth.layer.borderColor = UIColor.black.cgColor
            sixth.setTitleColor(.black, for: .normal)
            selectedStr = sixth.titleLabel?.text
        default:
            return
        }
        
        chosenString = num
        delegate?.didSelect(note: selectedStr!, strInd: num)
    }
    
    func setAllUnchosen() {
        for button in pegs {
            button.backgroundColor = .clear
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitleColor(.white, for: .normal)
        }
        chosenString = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol TuningViewDelegate: class {
    func didSelect(note: String, strInd: Int)
}


