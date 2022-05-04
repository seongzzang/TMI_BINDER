//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore

public func ShowScheduleList(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int) {
    let db = Firestore.firestore()
    
    var varScheduleTitles = scheduleTitles
    var varScheduleMemos = scheduleMemos
    var varCount: Int = count
    
    // 데이터베이스에서 일정 리스트 가져오기
    let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList")
    // Date field가 현재 날짜와 동일한 도큐먼트 모두 가져오기
    docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                // 사용할 것들 가져와서 지역 변수로 저장
                let scheduleTitle = document.data()["title"] as? String ?? ""
                let scheduleMemo = document.data()["memo"] as? String ?? ""
                
                if (!scheduleTitles.contains(scheduleTitle)) {
                    // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                    varScheduleTitles.append(scheduleTitle)
                    varScheduleMemos.append(scheduleMemo)
                }
                
                // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                varCount = scheduleTitles.count
            }
        }
    }
}

public func SetScheduleTexts(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int, scheduleCell : ScheduleCellTableViewCell, indexPathRow : Int) {
    // 데이터베이스에서 일정 리스트 가져오기
    let db = Firestore.firestore()
    
    var varScheduleTitles = scheduleTitles
    var varScheduleMemos = scheduleMemos
    var varCount: Int = count
    
    let docRef = db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList")
    // Date field가 현재 날짜와 동일한 도큐먼트 모두 가져오기
    docRef.whereField("date", isEqualTo: datestr).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                // 사용할 것들 가져와서 지역 변수로 저장
                let scheduleTitle = document.data()["title"] as? String ?? ""
                let scheduleMemo = document.data()["memo"] as? String ?? ""
                
                if (!varScheduleTitles.contains(scheduleTitle)) {
                    // 여러 개의 일정이 있을 수 있으므로 가져와서 배열에 저장
                    varScheduleTitles.append(scheduleTitle)
                    varScheduleMemos.append(scheduleMemo)
                }
                
                // 일정의 제목은 필수 항목이므로 일정 제목 개수만큼을 개수로 지정
                varCount = varScheduleTitles.count
            }
            for i in 0...indexPathRow {
                // 가져온 내용들을 순서대로 일정 셀의 텍스트로 설정
                scheduleCell.scheduleTitle.text = varScheduleTitles[i]
                scheduleCell.scheduleMemo.text = varScheduleMemos[i]
            }
        }
    }
}

public func GetUserAndClassInfo(self : TeacherEvaluationViewController) {
    let db = Firestore.firestore()
    /// parent collection / 현재 사용자 uid 경로에서 문서 찾기
    db.collection("parent").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
        if let document = document, document.exists { /// 문서 있으면
            let data = document.data()
            let childPhoneNumber = data!["childPhoneNumber"] as? String ?? "" // 학생(자녀) 휴대전화 번호
            ///  student collection에 가져온 학생 전화번호와 동일한 전화번호 정보를 가지는 문서 찾기
            db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print(">>>>> document 에러 : \(err)")
                } else {
                    /// 문서 있으면
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let studentName = document.data()["name"] as? String ?? "" // 학생 이름
                        self.studentName = studentName
                        
                        db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print(">>>>> document 에러 : \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("\(document.documentID) => \(document.data())")
                                    let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                                    
                                    /// parent collection / 현재 사용자 uid / teacherEvaluation collection / 선생님이름(선생님이메일) 과목 / evaluation 경로에서 문서 찾기
                                    db.collection("teacherEvaluation").document(teacherUid).collection("evaluation").document(studentName + " " + self.month).getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            let data = document.data()
                                            let teacherAttitude = data!["teacherAttitude"] as? String ?? "" // 선생님 태도 점수
                                            let teacherManagingSatisfyScore = data!["teacherManagingSatisfyScore"] as? String ?? "" // 학생 관리 만족도 점수
                                            self.teacherAttitude.text = teacherAttitude // 선생님 태도 점수 text 지정
                                            self.teacherManagingSatisfyScore.text = teacherManagingSatisfyScore // 학생 관리 만족도 점수 지정
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.studentTitle.text = studentName + " 학생의 " + self.date + " 수업은..." // 학생 평가 title text 설정
                        self.evaluationTextView.isEditable = false // 평가 textview 수정 못하도록 설정
                    }
                }
            }
        } else {
            print("Document does not exist")
        }
    }
}

public func GetEvaluation (self : TeacherEvaluationViewController) {
    let db = Firestore.firestore()
    // 데이터베이스 경로
    db.collection("teacher").whereField("email", isEqualTo: self.teacherEmail).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print(">>>>> document 에러 : \(err)")
        } else {
            for document in querySnapshot!.documents {
                print("\(document.documentID) => \(document.data())")
                let teacherUid = document.data()["uid"] as? String ?? "" // 선생님 uid
                self.teacherUid = teacherUid
                let parentDocRef = self.db.collection("parent")
                parentDocRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(">>>>> document 에러 : \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let childPhoneNumber = document.data()["childPhoneNumber"] as? String ?? ""
                            
                            db.collection("student").whereField("phonenum", isEqualTo: childPhoneNumber).getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print(">>>>> document 에러 : \(err)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        print("\(document.documentID) => \(document.data())")
                                        let studentEmail = document.data()["email"] as? String ?? "" // 학생 이메일
                                        let studentName = document.data()["name"] as? String ?? "" // 학생 이메일
                                        
                                        db.collection("teacher").document(teacherUid).collection("class").whereField("email", isEqualTo: studentEmail).getDocuments() { (querySnapshot, err) in
                                            if let err = err {
                                                print(">>>>> document 에러 : \(err)")
                                            } else {
                                                for document in querySnapshot!.documents {
                                                    print("\(document.documentID) => \(document.data())")
                                                    let subject = document.data()["subject"] as? String ?? ""
                                                    
                                                    db.collection("teacher").document(teacherUid).collection("class").document(studentName + "(" + studentEmail + ") " + subject).collection("Evaluation").whereField("evaluationDate", isEqualTo: self.date).getDocuments() { (querySnapshot, err) in
                                                        if let err = err {
                                                            print("Error getting documents: \(err)")
                                                        } else {
                                                            for document in querySnapshot!.documents {
                                                                print("\(document.documentID) => \(document.data())")
                                                                // 사용할 것들 가져와서 지역 변수로 저장
                                                                let evaluationMemo = document.data()["evaluationMemo"] as? String ?? "선택된 날짜에는 수업이 없었습니다."
                                                                let homeworkCompletion = document.data()["homeworkCompletion"] as? Int ?? 0
                                                                self.averageHomeworkCompletion.text = "\(homeworkCompletion) 점"
                                                                let classAttitude = document.data()["classAttitude"] as? Int ?? 0
                                                                self.averageClassAttitude.text = "\(classAttitude) 점"
                                                                let testScore = document.data()["testScore"] as? Int ?? 0
                                                                self.averageTestScore.text = "\(testScore) 점"
                                                                self.evaluationTextView.text = evaluationMemo
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

public func SaveTeacherEvaluation(self : TeacherEvaluationViewController) {
    let db = Firestore.firestore()
    /// parent collection / 현재 사용자 Uid / teacherEvaluation / 선생님이름(선생님이메일) / 현재 달 collection / evaluation 아래에 선생님 태도 점수와 학생 관리 만족도 점수 저장
    db.collection("teacherEvaluation").document(self.teacherUid).collection("evaluation").document(self.studentName + " " + self.month)
        .setData([
            "teacherUid": self.teacherUid,
            "teacherAttitude": self.teacherAttitude.text!,
            "teacherManagingSatisfyScore": self.teacherManagingSatisfyScore.text!
        ])
    { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}
