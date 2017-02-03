//
//  ViewController.swift
//  Translate
//
//  Created by Alexey Papin on 31.01.17.
//  Copyright © 2017 zzheads. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let apiClient = TranslateAPIClient()
    let alamoClient = AlamoAPIClient()
    
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var translatedLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    
    var languages = [TranslationLanguage]()
    
    var selectedLanguage: TranslationLanguage? {
        let index = pickerView.selectedRow(inComponent: 0)
        if (index >= languages.count) {
            return nil
        }
        return languages[index]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        translateButton.addTarget(self, action: #selector(translatePressed(_:)), for: .touchUpInside)

        alamoClient.fetch(endpoint: TranslateEndpoint.languages) { (languages: [TranslationLanguage]?) in
            guard let languages = languages else {
                return
            }
            self.languages = languages
            self.pickerView.reloadAllComponents()
        }
     
        textField.addTarget(self, action: #selector(translatePressed(_:)), for: .editingDidEndOnExit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = languages[row].name
        label.font = AppFont.sanFranciscoDisplayRegular(size: 15.0).font
        label.textColor = .white
        label.textAlignment = .center
        return label
    }
}

extension ViewController {
    @objc fileprivate func translatePressed(_ sender: Any) {
        guard
            let text = textField.text,
            let to = selectedLanguage
            else {
                return
        }

        alamoClient.fetch(endpoint: TranslateEndpoint.translate(text: text, from: nil, to: to.code)) { (translates: [TranslationResponse]?) in
            guard
                let translates = translates,
                let translate = translates.first
                else {
                return
            }
            self.translatedLabel.text = translate.translationText
        }
        
    }
}
