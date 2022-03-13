//
//  StudentEvaluationCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/03/11.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class StudentEvaluationCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let months = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    var evaluations: [String] = []
    
    @IBOutlet weak var classColorView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var monthPickerView: UITextField!
    @IBOutlet weak var monthlyEvaluationTextView: UITextView!
    @IBOutlet weak var showMoreInfoButton: UIButton!
    
    var selectedMonth = ""
    var evaluation = ""
    var studentUid = ""
    var teacherName = ""
    var teacherEmail = ""
    var subject = ""
    
    func setStudentUID(_ studentUid: String) {
        self.studentUid = studentUid
    }
    
    func setTeacherInfo(_ teacherName: String, _ teacherEmail: String, _ subject: String) {
        self.teacherName = teacherName
        self.teacherEmail = teacherEmail
        self.subject = subject
        getEvaluation()
    }
    
    @IBAction func ShowMoreInfoBtnClicked(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.clipsToBounds = true
        cellBackgroundView.layer.cornerRadius = 15
        
        createPickerView()
        dismissPickerView()
        
        classColorView.makeCircle()
        
        monthPickerView.backgroundColor = .white
        monthPickerView.borderStyle = .none
        monthPickerView.textAlignment = .right
        monthPickerView.clipsToBounds = true
        monthPickerView.layer.cornerRadius = 10
        monthPickerView.rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5.0, height: 0.0))
        monthPickerView.rightViewMode = .always
        monthlyEvaluationTextView.textContainer.maximumNumberOfLines = 3
        monthlyEvaluationTextView.isScrollEnabled = false
        monthlyEvaluationTextView.textContainer.lineBreakMode = .byTruncatingTail
        
//        self.monthlyEvaluationTextView.text = "1월"
//        self.selectedMonth = months[0]
        
        self.selectionStyle = .none
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return months[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedMonth = months[row]
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        monthPickerView.tintColor = .clear
        
        monthPickerView.inputView = pickerView
    }
    
    func getEvaluation() {
        let db = Firestore.firestore()
        db.collection("parent").whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(">>>>> document 에러 : \(err)")
            } else {
                /// nil이 아닌지 확인한다.
                guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                    return
                }
                for document in snapshot.documents {
                    print(">>>>> document 정보 : \(document.documentID) => \(document.data())")
                    /// nil값 처리
                    let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                    db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print(">>>>> document 에러 : \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID) => \(document.data())")
                                let studentUid = document.data()["uid"] as? String ?? ""
                                
                                print ("path : \(self.teacherName + "(" + self.teacherEmail + ") " + self.subject), self.selectedMonth : \(self.selectedMonth)")
                                
                                db.collection("student").document(studentUid).collection("class").document(self.teacherName + "(" + self.teacherEmail + ") " + self.subject).collection("Evaluation").whereField("month", isEqualTo: self.selectedMonth).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print(">>>>> document 에러 : \(err)")
                                    } else {
                                        self.setTextView("등록된 평가가 없습니다.")
                                        self.monthPickerView.text = "\(self.selectedMonth)"
                                        for document in querySnapshot!.documents {
                                            let evaluation = document.data()["evaluation"] as? String ??  "등록된 평가가 없습니다."
                                            print ("NO ERROR IN HERE : evaluation : \(evaluation)")
                                            self.setTextView(evaluation)
                                            self.monthPickerView.text = "\(self.selectedMonth)"
                                        }
                                        self.monthPickerView.resignFirstResponder()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(donePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBT = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        monthPickerView.inputAccessoryView = toolBar
    }
    
    func setTextView(_ Evaluation: String) {
        self.monthlyEvaluationTextView.text = Evaluation
    }
    
    @objc func donePicker() {
        getEvaluation()
    }
    
    @objc func cancelPicker() {
        monthPickerView.resignFirstResponder()
    }
}
