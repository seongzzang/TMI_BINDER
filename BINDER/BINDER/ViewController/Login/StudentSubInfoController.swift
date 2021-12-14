//
//  StudentSubInfoController.swift
//  BINDER
//
//  Created by 양성혜 on 2021/12/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class StudentSubInfoController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    @IBOutlet weak var ageShowPicker: UITextField!
    @IBOutlet weak var phonenumTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    let agelist = ["초등학생","중학생","고등학생","일반인"]
    var age = "0"
    var phonenum = "0"
    var goal = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        ageLabel.text = nil
        phoneLabel.text = nil
        goalLabel.text = nil
        
        createPickerView()
        dismissPickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }


    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return agelist.count
    }


    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        age = agelist[row]
        return agelist[row]
        }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ageShowPicker.text = agelist[row]
        }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        ageShowPicker.tintColor = .clear
        
        ageShowPicker.inputView = pickerView
      }

      func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBT = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: true)
        toolBar.isUserInteractionEnabled = true

        ageShowPicker.inputAccessoryView = toolBar
      }
    
    @objc func donePicker() {
        ageShowPicker.text = "\(age)"
        self.ageShowPicker.resignFirstResponder()
        
    }
    
    @objc func cancelPicker() {
        ageShowPicker.resignFirstResponder()
    }

    
    @IBAction func goNext(_ sender: Any) {
        phonenum = phonenumTextField.text!
        goal = goalTextField.text!
        if age == "0" {
            ageLabel.text = "하나를 선택해주세요"
        }
        else if phonenum == "" {
            phoneLabel.text = "전화번호를 작성해주세요"
        }
        else if goal == "" {
            goalLabel.text = "목표를 작성해주세요"
        }
        else {
            // 데이터 저장
           db.collection("student").document(Auth.auth().currentUser!.uid).updateData([
                "age": age,
                "phonenum": phonenum,
                "goal": goal
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
            
            guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                //아니면 종료
                return
            }
            
            guard let myClassVC = self.storyboard?.instantiateViewController(withIdentifier: "MyClassVC") as? MyClassVC else {
                return
            }
            
            guard let questionVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionVC") as? QuestionViewController else {
                return
            }
            
            guard let myPageVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as? MyPageViewController else {
                return
            }
          
            let tb = UITabBarController()
            tb.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            tb.setViewControllers([homeVC, myClassVC, questionVC, myPageVC], animated: true)
            self.present(tb, animated: true, completion: nil)

        }
    }
    
}
