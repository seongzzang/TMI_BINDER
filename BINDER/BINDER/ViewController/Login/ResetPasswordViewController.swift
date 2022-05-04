//
//  ResetPasswordViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/04/04.
//

import UIKit
import Firebase
import FirebaseAuth
import Firebase
import AuthenticationServices

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    
    var btnDesign = ButtonDesign()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendBtn.clipsToBounds = true
        sendBtn.layer.cornerRadius = btnDesign.cornerRadius
    }
    
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func SendMailToReset (_ sender: Any) {
        if (isValidEmail(emailTextField.text!)) {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!)
            emailTextField.isEnabled = false
            alertLabel.text = "입력하신 이메일 주소로\n비밀번호 재설정 메일이 전송되었습니다!"
            alertLabel.isHidden = false
        } else {
            alertLabel.text = StringUtils.emailValidationAlert.rawValue
            alertLabel.isHidden = false
        }
    }
    
    @IBAction func LogInBtnClicked (_ sender: Any) {
        // 로그인 화면(첫화면)으로 다시 이동
        self.dismiss(animated: true)
    }
}
