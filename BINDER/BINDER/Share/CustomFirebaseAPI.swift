//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

public var publicTitles: [String] = []
public var varCount = 0
public var varIsEdited = false

public func ShowScheduleList(type : String, date : String, datestr: String, scheduleTitles : [String], scheduleMemos : [String], count : Int) {
    let db = Firestore.firestore()
    
    var varScheduleTitles = scheduleTitles
    var varScheduleMemos = scheduleMemos
    varCount = count
    
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
    varCount = count
    
    publicTitles.removeAll()
    
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
                    publicTitles.append(scheduleTitle)
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

public func DeleteSchedule(type : String, date : String , indexPathRow : Int, scheduleListTableView : UITableView) {
    let db = Firestore.firestore()
    
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(publicTitles[indexPathRow]).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
            varCount = varCount - 1
            scheduleListTableView.reloadData()
        }
    }
    
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").getDocuments()
    {
        (querySnapshot, err) in
        
        if let err = err
        {
            print("Error getting documents: \(err)");
        }
        else
        {
            var count = 0
            for document in querySnapshot!.documents {
                count += 1
                print("\(document.documentID) => \(document.data())");
            }
            
            if (count == 1) {
                db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").setData(["count": 0])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            } else {
                db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document("Count").setData(["count": count-1])
                { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                }
            }
        }
    }
}

public func EditSchedule(type : String, date : String, editingTitle : String, isEditMode : Bool, scheduleMemoTV : UITextView, schedulePlaceTF : UITextField, scheduleTitleTF : UITextField, scheduleTimeTF : UITextField) {
    let db = Firestore.firestore()
    varIsEdited = isEditMode
    
    // 내용이 있다는 의미이므로 데이터베이스에서 다시 받아와서 textfield의 값으로 설정
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(editingTitle).getDocument { (document, error) in
        if let document = document, document.exists {
            varIsEdited = true
            let data = document.data()
            let memo = data?["memo"] as? String ?? ""
            scheduleMemoTV.text = memo
            let place = data?["place"] as? String ?? ""
            schedulePlaceTF.text = place
            let title = data?["title"] as? String ?? ""
            scheduleTitleTF.text = title
            let time = data?["time"] as? String ?? ""
            scheduleTimeTF.text = time
        } else {
            print("Document does not exist")
        }
    }
}

public func SaveEditSchedule(type : String, date : String, editingTitle : String, isEditMode : Bool, scheduleMemoTV : UITextView, schedulePlaceTF : UITextField, scheduleTitleTF : UITextField, scheduleTimeTF : UITextField, datestr : String, current_time_string : String) {
    // 원래 데이터베이스에 저장되어 있던 일정은 삭제하고 새롭게 수정한 내용으로 추가 후 현재 modal dismiss
    let db = Firestore.firestore()
    print ("editing Title : \(editingTitle)")
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(editingTitle).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
        }
    }
    
    db.collection(type).document(Auth.auth().currentUser!.uid).collection("schedule").document(date).collection("scheduleList").document(scheduleTitleTF.text!).setData([
        "title": scheduleTitleTF.text!,
        "place": schedulePlaceTF.text!,
        "date" : datestr,
        "time": scheduleTimeTF.text!,
        "memo": scheduleMemoTV.text!,
        "savedTime": current_time_string ])
    { err in
        if let err = err {
            print("Error adding document: \(err)")
        }
    }
}
