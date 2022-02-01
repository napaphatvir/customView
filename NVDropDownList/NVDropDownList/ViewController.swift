//
//  ViewController.swift
//  NVDropDownList
//
//  Created by boicomp21070029 on 19/11/2564 BE.
//

import UIKit
extension UIView {
    func roundCorner(corner: CGFloat, roundingCorner: UIRectCorner, animationDuration: TimeInterval = 0) {
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds,
                                 byRoundingCorners: roundingCorner,
                                 cornerRadii: CGSize(width: corner, height: corner)).cgPath
        
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1
        animation.fromValue = (layer.mask as? CAShapeLayer)?.path
        animation.toValue = UIBezierPath(roundedRect: bounds,
                                         byRoundingCorners: roundingCorner,
                                         cornerRadii: CGSize(width: corner, height: corner)).cgPath
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = .forwards
        mask.add(animation, forKey: "path")
        
        
        layer.mask = mask

    }
}

class ViewController: UIViewController {
    @IBOutlet weak var viewContent: CustomView!
    @IBOutlet weak var cstHeight: NSLayoutConstraint!
    var isExpand = false
    let items = ["Item 1", "Item 2", "Item 3", "Item 4",
                 "Item 5", "Item 6", "Item 7", "Item 8",
                 "Item 9", "Item 10", "Item 11", "Item 12",
                 "Item 13", "Item 14", "Item 15", "Item 16",
                 "Item 17", "Item 18", "Item 19", "Item 20"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNav()
//        self.viewContent.roundCorner(corner: 15, roundingCorner: [.bottomLeft, .bottomRight])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewContent.roundCorner(corner: 15, roundingCorner: [.bottomLeft, .bottomRight])
    }
    
    func initNav() {
        navigationItem.titleView = createDropdown()
    }
    
    @IBAction func clickAnimate(_ sender: Any) {
        
        cstHeight.constant = isExpand ? 150 : 300
        isExpand.toggle()
//        self.viewContent.roundCorner(corner: 15, roundingCorner: [.bottomLeft, .bottomRight])
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
            self.view.layoutIfNeeded()
            
        })
    }
    
    func createDropdown() -> UIView? {
        let view = NVDropDownView(navigationController: navigationController!)
        view.dataSource = self
        view.delegate = self
        return view
    }
}

extension ViewController: NVTableViewDataSource, NVTableViewDelegate {
    func nvTableView(_ nvTableView: NVTableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func nvTableView(_ nvTableView: NVTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = items[indexPath.row]
        cell.detailTextLabel?.text = items[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.contentView.backgroundColor = .blue
        return cell
    }
    
    func nvTableView(_ nvTableView: NVTableView, didSelectRowAt indexPath: IndexPath) {
        //Do Something
    }
}

