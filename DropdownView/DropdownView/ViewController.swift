//
//  ViewController.swift
//  DropdownView
//
//  Created by boicomp21070029 on 1/2/2565 BE.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    
    lazy var dropdownView: DropdownView = {
        let dropdown = DropdownView()
        dropdown.maximumHeight = 300
        dropdown.adjustHeightMode = .automatic
        dropdown.adjustWidthMode = .automatic
        dropdown.animate = true
        dropdown.animationOption = .slide
        return dropdown
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dropdownView.anchorView = button
        dropdownView.delegate = self
        dropdownView.dataSource = self
        dropdownView.appearance.addCornerRadius(radius: 3)
        dropdownView.appearance.addShadow(radius: 5, color: .black, opacity: 0.2, offset: CGSize(width: 0, height: 2))
        view.addSubview(dropdownView)
    }

    @IBAction func tapButton(_ sender: Any) {
        dropdownView.toggle()
    }
}

extension ViewController: DropdownViewDataSource {
    func numberOfRows(in dropDownView: DropdownView) -> Int {
        20
    }
    
    func dropDownView(_ dropDownView: DropdownView, cellForRowAt index: Int) -> UITableViewCell? {
        let cell = dropdownView.defaultCell(for: index)
        cell.textLabel?.text = String(index + 1)
        cell.textLabel?.textAlignment = .center
        return cell
    }
}

extension ViewController: DropdownViewDelegate {
    func dropDownView(_ dropDownView: DropdownView, didSelectRowAt index: Int) {
        print(index)
    }
}



