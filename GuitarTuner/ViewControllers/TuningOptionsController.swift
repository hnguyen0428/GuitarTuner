//
//  TuningOptionsController.swift
//  GuitarTuner
//
//  Created by Hoang on 12/27/17.
//  Copyright © 2017 Hoang. All rights reserved.
//

import UIKit

let tuningTypes: [String] = ["", "EADGBE", "DADGBE", "DADF#AD",
                             "CGCGCE", "EAC#EAE", "BF#BF#BD#", "EBEG#BE",
                             "FACFCF", "DGDGBD", "D#G#C#F#A#D#",
                             "DGCFAD", "FADGBE", "DADGAD", "DADDAD",
                             "C#G#C#F#A#D#"]
let tuningNames: [String: String] = [
    "": "",
    "EADGBE": "Standard Tuning (E-A-D-G-B-E)",
    "DADGBE": "Drop D (D-A-D-G-B-E)",
    "DADF#AD": "Open D Tuning (D-A-D-F#-A-D)",
    "CGCGCE": "Open C Tuning (C-G-C-G-C-E)",
    "EAC#EAE": "Open A Tuning (E-A-C#-E-A-E)",
    "BF#BF#BD#": "Open B Tuning (B-F#-B-F#-B-D#)",
    "EBEG#BE": "Open E Tuning (E-B-E-G#-B-E)",
    "FACFCF": "Open F Tuning (F-A-C-F-C-F)",
    "DGDGBD": "Open G Tuning (D-G-D-G-B-D)",
    "D#G#C#F#A#D#": "Half step (D#-G#-C#-F#-A#-D#)",
    "DGCFAD": "One step down (D-G-C-F-A-D)",
    "FADGBE": "F-A-D-G-B-E",
    "DADGAD": "D-A-D-G-A-D",
    "DADDAD": "D-A-D-D-A-D",
    "C#G#C#F#A#D#": "C#-G#-C#-F#-A#-D#"
]

class TuningOptionsController: UIViewController, UIPickerViewDelegate,
                                UIPickerViewDataSource, UITextFieldDelegate {
    
    var chosenTuning: String? = nil
    var chosenTuningName: String? = nil
    
    var textfield: UITextField!
    var label: UILabel!
    var tuneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(r: 50, g: 50, b: 50)
        setupTextfield()
        setupLabel()
        setupTuneButton()
        setupPicker()
        
        restoreLastTuning()
        
        self.title = "GuitarTuner"
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    func setupTextfield() {
        let width = view.frame.width * 0.60
        let height = view.frame.height * 0.05
        
        textfield = UITextField()
        textfield.backgroundColor = .black
        textfield.alpha = 0.5
        textfield.layer.cornerRadius = 10.0
        textfield.textAlignment = .center
        textfield.textColor = .white
        textfield.tintColor = .clear
        textfield.delegate = self
        
        view.addSubview(textfield)
        
        textfield.translatesAutoresizingMaskIntoConstraints = false
        
        textfield.widthAnchor.constraint(equalToConstant: width).isActive = true
        textfield.heightAnchor.constraint(equalToConstant: height).isActive = true
        textfield.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let barOffset = self.navigationController?.navigationBar.frame.height
        let topOffset = view.frame.height * 0.20
        textfield.topAnchor.constraint(equalTo: view.topAnchor,
                                       constant: barOffset! + topOffset).isActive = true
        
    }
    
    func setupLabel() {
        let width = view.frame.width * 0.60
        let height = view.frame.height * 0.05
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Choose tuning type"
        label.textAlignment = .center
        
        view.addSubview(label)
        
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
        label.heightAnchor.constraint(equalToConstant: height).isActive = true
        label.bottomAnchor.constraint(equalTo: textfield.topAnchor, constant: -20.0).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setupTuneButton() {
        let width = view.frame.width * 0.30
        let height = view.frame.height * 0.06
        
        tuneButton = UIButton()
        tuneButton.translatesAutoresizingMaskIntoConstraints = false
        tuneButton.setTitle("Start Tuning", for: .normal)
        tuneButton.layer.cornerRadius = 10.0
        tuneButton.backgroundColor = .darkGray
        tuneButton.isEnabled = false
        tuneButton.alpha = 0.7
        
        view.addSubview(tuneButton)
        
        tuneButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        tuneButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        tuneButton.topAnchor.constraint(equalTo: textfield.bottomAnchor, constant: 20.0).isActive = true
        tuneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tuneButton.addTarget(self, action: #selector(startTuning), for: .touchUpInside)
    }
    
    func setupPicker() {
        let pickerView: UIPickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .darkGray
        textfield.inputView = pickerView
    }
    
    func restoreLastTuning() {
        let lastTuning = UserDefaults.standard.object(forKey: "last_tuning") as? String
        if let tuning = lastTuning {
            chosenTuning = tuning
            chosenTuningName = tuningNames[tuning]
            textfield.text = chosenTuningName
            tuneButton.isEnabled = true
            tuneButton.alpha = 1.0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            tuneButton.isEnabled = false
            tuneButton.alpha = 0.7
        }
        else {
            tuneButton.isEnabled = true
            tuneButton.alpha = 1.0
        }
        chosenTuning = tuningTypes[row]
        chosenTuningName = tuningNames[chosenTuning!]
        
        textfield.text = chosenTuningName
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tuningNames[tuningTypes[row]]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tuningTypes.count
    }
    
    @objc func startTuning(_ sender: UIButton) {
        let tvc = TuningViewController()
        tvc.chosenTuning = chosenTuning
        tvc.chosenTuningName = chosenTuningName
        
        self.navigationController?.pushViewController(tvc, animated: true)
        
        UserDefaults.standard.set(chosenTuning, forKey: "last_tuning")
        UserDefaults.standard.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
