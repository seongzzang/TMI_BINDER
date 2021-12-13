//
//  HomeViewController.swift
//  BINDER
//
//  Created by 김가은 on 2021/11/20.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FSCalendar

// 홈 뷰 컨트롤러
class HomeViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var emailVerificationCheckBtn: UIButton!
    @IBOutlet weak var calendarView: FSCalendar!
    
    var id : String = ""
    var pw : String = ""
    var name : String = ""
    var number : Int = 1
    var verified : Bool = false
    var type : String = ""
    
    var events = [Date]()
    var date : String!
    
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
    // 캘린더 외관을 꾸미기 위한 메소드
    func calendarColor() {
        calendarView.appearance.weekdayTextColor = .systemGray
        calendarView.appearance.titleWeekendColor = .black
        calendarView.appearance.headerTitleColor =  UIColor.init(red: 19/255, green: 32/255, blue: 62/255, alpha: 100)
        calendarView.appearance.eventDefaultColor = .systemPink
        calendarView.appearance.selectionColor = .none
        calendarView.appearance.titleSelectionColor = .black
        calendarView.appearance.todayColor = .systemOrange
        calendarView.appearance.todaySelectionColor = .systemOrange
        calendarView.appearance.borderSelectionColor = .systemOrange
    }
    
    // 캘린더 텍스트 스타일 설정을 위한 메소드
    func calendarText() {
        calendarView.headerHeight = 50
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleFont = UIFont.systemFont(ofSize: 25, weight: .bold)
        calendarView.appearance.titleFont = UIFont.systemFont(ofSize: 15)
        calendarView.locale = Locale(identifier: "ko_KR")
    }
    
    func calendarEvent() {
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    // 화면 터치 시 키보드 내려가도록 하는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
   }
    
    // 이벤트 추가하기 (날짜를 events 배열에 추가)
    func setUpEvents(_ eventDate: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd EEEE"
        let event = formatter.date(from: eventDate)
        let sampledate = formatter.date(from: eventDate)
        events = [event!, sampledate!]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        calendarView.delegate = self
        verifiedCheck() // 인증된 이메일인지 체크하는 메소드
        
        self.calendarText()
        self.calendarColor()
        self.calendarEvent()
        
        // 인증되지 않은 계정이라면
        if (!verified) {
            stateLabel.text = "작성한 이메일로 인증을 진행해주세요."
            emailVerificationCheckBtn.isHidden = false
            calendarView.isHidden = true // 캘린더 뷰 안 보이도록 함
        } else {
            // 인증되었고,
            if (self.type == "teacher") { // 선생님 계정이라면
                getTeacherInfo()
                if (Auth.auth().currentUser?.email != nil) {
                    calendarView.isHidden = false
                    emailVerificationCheckBtn.isHidden = true
                }
            } else {
                // 학생 계정이라면
                getStudentInfo()
                if (Auth.auth().currentUser?.email != nil) {
                    calendarView.isHidden = false
                    emailVerificationCheckBtn.isHidden = true
                }
            }
        }
    }
    
    func getTeacherInfo(){
        // 데이터베이스 경로
        let docRef = self.db.collection("teacher").document(Auth.auth().currentUser!.uid)
        
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["Name"] as? String ?? ""
                self.stateLabel.text = self.name + " 선생님 환영합니다!"
                self.id = data?["Email"] as? String ?? ""
                self.pw = data?["Password"] as? String ?? ""
                self.type = data?["Type"] as? String ?? ""
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getStudentInfo(){
        // 데이터베이스 경로
        let docRef = self.db.collection("student").document(Auth.auth().currentUser!.uid)
        
        // 존재하는 데이터라면, 데이터 받아와서 각각 변수에 저장
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["Name"] as? String ?? ""
                self.stateLabel.text = self.name + " 학생 환영합니다!"
                self.id = data?["Email"] as? String ?? ""
                self.pw = data?["Password"] as? String ?? ""
                self.type = data?["Type"] as? String ?? ""
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func verifiedCheck() {
        getStudentInfo() // 학생 정보 받아오기
        getTeacherInfo() // 선생님 정보 받아오기
        // id와 pw 변수에 저장된 걸로 로그인 진행
        Auth.auth().signIn(withEmail: id, password: pw) { result, error in
            let check = Auth.auth().currentUser?.isEmailVerified // 이메일 인증 여부
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if (check == false) {
                    self.verified = false // 인증 안 되었으면 false 설정
                } else {
                    self.verified = true // 인증 되었으면 true 설정
                }
            }
        }
    }
    
    // 인증 확인 버튼 클릭시 실행되는 메소드
    @IBAction func CheckVerification(_ sender: Any) {
        verifiedCheck() // 이메일 인증 여부 확인 메소드 실행
        if (verified == false) { // false면,
            stateLabel.text = "이메일 인증이 진행중입니다."
            emailVerificationCheckBtn.isHidden = false
        } else { // true면,
            if (Auth.auth().currentUser?.email != nil) {
                if (type == "teacher") { // 선생님 계정이면
                    stateLabel.text = name + " 선생님 환영합니다!"
                } else if (type == "student") { // 학생 계정이면
                    stateLabel.text = name + " 학생 환영합니다!"
                }
                calendarView.isHidden = false // 캘린더 뷰 숨겨둔 거 보여주기
                emailVerificationCheckBtn.isHidden = true // 이메일 인증 확인 버튼 숨기기
            }
        }
    }
}

extension HomeViewController: FSCalendarDelegate, UIViewControllerTransitioningDelegate {
    // 날짜 선택 시 실행되는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        // 일정 리스트 뷰 보여주기
        guard let scheduleListVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleListViewController") as? ScheduleListViewController else { return }
        // 데이터베이스의 Count document에서 count 정보를 받아서 전달
        self.db.collection("Schedule").document(Auth.auth().currentUser!.uid).collection(dateFormatter.string(from: date)).document("Count").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
            scheduleListVC.count = data["count"] as! Int
        }
        // 날짜 데이터 변수에 저장
        self.date = dateFormatter.string(from: date)
        setUpEvents(dateFormatter.string(from: date))
        
        // 날짜 데이터 넘겨주기
        scheduleListVC.date = dateFormatter.string(from: date)
        self.present(scheduleListVC, animated: true, completion: nil)
    }
}

extension HomeViewController: FSCalendarDataSource {
    
}
