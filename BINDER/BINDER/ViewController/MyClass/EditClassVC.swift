//
//  editClassVC.swift
//  BINDER
//
//  Created by 하유림 on 2022/03/09.
//

import UIKit
import Firebase

class EditClassVC : UIViewController {
    
    // 연결
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var payTypeBtn: UIButton!
    @IBOutlet weak var payAmountTF: UITextField!
    @IBOutlet weak var payDateTF: UITextField!
    @IBOutlet weak var repeatYNToggle: UISwitch!
    @IBOutlet var daysBtn: [UIButton]!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBAction func cancelBtnAction(_ sender: Any) {
        if let preVC = self.presentingViewController as? UIViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var okBtn: UIButton!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    
    // 이 부분 주석 처리 해제해야 1 코드 적용 했을 때 정상 작동
//    var userName = ""
//    var userEmail = ""
//    var userSubject = ""
    
    var subject = ""
    var payType = ""
    var payAmount = ""
    var payDate = ""
    var repeatYN = ""
    var days = ""
    
    // var teacherItem: TeacherItem!
    var studentItem: StudentItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.userName + "(" + self.userEmail + ") " + self.userSubject - 1
        // 에러 뜨는 위치 path에 위에 주석처리한 것처럼 하면 작동 되긴 함
        // 대신 DetailClassViewController에서 정보 넘기는 코드랑 위에 userName, userEmail, userSubject 변수 주석 처리 해제해야 함
        
        db.collection("teacher").document(Auth.auth().currentUser!.uid).collection("class").document(self.studentItem.name + "(" + self.studentItem.email + ") " + self.subjectTF.text!).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                let subject = data?["subject"] as? String ?? ""
                self.subjectTF.text = subject
                
                let payType = data?["payType"] as? String ?? ""
                if (payType == "C") {
                    self.payTypeBtn.setTitle("회차별", for: .normal)
                } else {
                    self.payTypeBtn.setTitle("시간별", for: .normal)
                }
                
                let payAmount = data?["payAmount"] as? String ?? ""
                self.payAmountTF.text = payAmount
                
                let repeatYN = data?["repeatYN"] as? Bool ?? true
                if (repeatYN == true) {
                    self.repeatYNToggle.setOn(true, animated: true)
                } else {
                    self.repeatYNToggle.setOn(false, animated: true)
                }
                
                let schedule = data?["schedule"] as? String ?? ""
//                 저장된 스케줄을 " " 단위로 갈라내어 배열로 저장함
                schedule.components(separatedBy: " ")
                print(schedule[schedule.startIndex])

                
                
                
            } else {
                print("Document does not exist")
            }
        }
        
        
        
        
    }
    
}

extension String {
    func getChar(at index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
