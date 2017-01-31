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

        apiClient.fetchArray(endpoint: TranslateEndpoint.languages) { (result: APIResultArray<TranslationLanguage>) in
            switch result {
            case .Success(let languages):
                self.languages = languages
                self.pickerView.reloadAllComponents()
            case .Failure(let error):
                print(error)
            }
        }
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
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }
}

extension ViewController {
    @objc fileprivate func translatePressed(_ sender: UIButton) {
        guard
            let text = textField.text,
            let to = selectedLanguage
            else {
                return
        }
        
        apiClient.fetch(endpoint: TranslateEndpoint.translate(text: text, from: nil, to: to.code)) { (result: APIResult<TranslationResponse>) in
            switch result {
            case .Success(let translation):
                self.translatedLabel.text = translation.translationText
            case .Failure(let error):
                print(error)
            }
        }
        
    }
}
