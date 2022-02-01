//
//  ViewController.swift
//  StrechyHeader
//
//  Created by boicomp21070029 on 19/12/2564 BE.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let uiTableView = UITableView()
        uiTableView.delegate = self
        uiTableView.dataSource = self
        uiTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return uiTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupHeader()
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupHeader() {
        let stretchyView = StretchyTableHeaderView()
        stretchyView.height = 250
        tableView.tableHeaderView = stretchyView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let stretchyHeaderView = tableView.tableHeaderView as? StretchyTableHeaderView {
            stretchyHeaderView.scrollViewDidScroll(scrollView)
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row + 1)"
        return cell
    }
}

