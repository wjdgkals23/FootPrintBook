//
//  AnnotationTableViewController.swift
//  FootPrintGram
//
//  Created by 정하민 on 12/08/2019.
//  Copyright © 2019 JHM. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AnnotationTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var annotationList: FootPrintAnnotationList!
    var selected: FootPrintAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isUserInteractionEnabled = true
        let slideDownAction = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeDown))
        slideDownAction.direction = .down
        self.view.addGestureRecognizer(slideDownAction)
        
        annotationList = FootPrintAnnotationList.shared
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(annotationList.getList() == nil) {
            return 0
        }
        return annotationList.getList()!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let customcell = cell as! FootPrintTableCell
        customcell.title.text = annotationList.getList()![indexPath.row].post.title
        customcell.date.text = annotationList.getList()![indexPath.row].post.created
        return customcell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = annotationList.getList()![indexPath.row]
        for item in self.navigationController!.viewControllers {
            if item is MapViewController {
                let mapView = item as! MapViewController
                mapView.selectedAnnotation = selected
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(annotationList.getList()![indexPath.row].id!)
            FireBaseUtil.shared.deleteTotalFunc(indexPath.row, annotationList.getList()![indexPath.row].id!).done { (result) in
                self.navigationController?.popViewController(animated: true)
                }.catch { (err) in
                    self.failRegister(message: "삭제로딩실패")
            }
        }
    }
    
    
    @objc func swipeDown(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .down {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
