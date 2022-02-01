//
//  NVDropDownView.swift
//  NVDropDownList
//
//  Created by boicomp21070029 on 19/11/2564 BE.
//

import UIKit

protocol NVTableViewDelegate: AnyObject {
    func nvTableView(_ nvTableView: NVTableView, didSelectRowAt indexPath: IndexPath)
}

protocol NVTableViewDataSource: AnyObject {
    func nvTableView(_ nvTableView: NVTableView, numberOfRowsInSection section: Int) -> Int
    func nvTableView(_ nvTableView: NVTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

@objc protocol NVDropDownViewDelegate: AnyObject {
    func numberOfRows() -> Int
    func cellForRowAt() -> UITableViewCell
}

final class NVDropDownView: UIView {
    //Public Properties
    weak var delegate: NVTableViewDelegate?
    weak var dataSource: NVTableViewDataSource? { didSet { tableView.reloadData() } }
    
    var configuration = Configuration()
    
    //Private Properties
    private var menuView = UIView()
    private var backgroundView = UIView()
    private let lblTitle = UILabel()
    private let imageArrow = UIImageView()
    private var tableView = NVTableView()
    
    private var navigationController: UINavigationController!
    private var isExpand = false
    private var isAnimate = false
    private let cstTopIdentifier = "Menu-Top-Constraint"
    private let cstHeightIdentifier = "Menu-Height-Constraint"
    private var offsetTop: CGFloat {
        return navigationController.navigationBar.frame.height + statusBarHeight
    }
    private var statusBarHeight: CGFloat {
        if #available(iOS 13, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let constraint = navigationController.view.constraints.first(where: { $0.identifier == cstTopIdentifier }) {
            constraint.constant = offsetTop
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let frame = CGRect(origin: .zero,
                           size: CGSize(width: navigationController.navigationBar.bounds.width/1.5,
                                        height: navigationController.navigationBar.bounds.height))
        super.init(frame: frame)
        
        initTitle()

        guard let containerView = navigationController.view else { return }
        initDropDown(containerView: containerView)
        tableView.reloadData()
    }
    
    private func initTitle() {
        lblTitle.text = "Title"
        lblTitle.textAlignment = configuration.title.textAlignment
        lblTitle.font = configuration.title.font
        lblTitle.textColor = configuration.title.textColor
        
        imageArrow.image = configuration.arrowImage.down

        let btnTitle = UIButton()
        btnTitle.addTarget(self, action: #selector(tapTitle), for: .touchUpInside)
        
        addSubview(lblTitle)
        addSubview(imageArrow)
        addSubview(btnTitle)
        
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        imageArrow.translatesAutoresizingMaskIntoConstraints = false
        btnTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lblTitle.topAnchor.constraint(equalTo: topAnchor),
            lblTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
            lblTitle.leftAnchor.constraint(equalTo: leftAnchor),
            
            imageArrow.centerYAnchor.constraint(equalTo: lblTitle.centerYAnchor),
            imageArrow.leftAnchor.constraint(equalTo: lblTitle.rightAnchor, constant: 4),
            imageArrow.rightAnchor.constraint(equalTo: rightAnchor),
            imageArrow.heightAnchor.constraint(equalToConstant: 20),
            imageArrow.widthAnchor.constraint(equalTo: imageArrow.heightAnchor, multiplier: 1),
            
            btnTitle.topAnchor.constraint(equalTo: topAnchor),
            btnTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
            btnTitle.leftAnchor.constraint(equalTo: leftAnchor),
            btnTitle.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func initDropDown(containerView: UIView) {
        menuView.isHidden = true
        menuView.backgroundColor = .clear
        
        backgroundView.backgroundColor = configuration.maskBackgroundColor
        backgroundView.alpha = 0
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBackground)))
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = configuration.backgroundColor
        
        menuView.addSubview(backgroundView)
        menuView.addSubview(tableView)
        containerView.addSubview(menuView)
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: menuView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: offsetTop)
        topConstraint.identifier = cstTopIdentifier
        
        let heightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        heightConstraint.identifier = cstHeightIdentifier
        
        NSLayoutConstraint.activate([
            topConstraint,
            menuView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            menuView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            menuView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            
            tableView.topAnchor.constraint(equalTo: menuView.topAnchor),
            tableView.leftAnchor.constraint(equalTo: menuView.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: menuView.rightAnchor),
            heightConstraint,
            
            backgroundView.topAnchor.constraint(equalTo: menuView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: menuView.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: menuView.rightAnchor)
        ])
        containerView.layoutIfNeeded()
    }
    
    @objc private func tapTitle() {
        if isAnimate { return }
        isExpand.toggle()
        if isExpand {
            showDropDown()
        } else {
            hideDropDown()
        }
    }
    
    @objc private func tapBackground() {
        hideDropDown()
    }
    
    private func showDropDown() {
        if isAnimate { return }
        isAnimate = true
        menuView.isHidden = false
        imageArrow.image = configuration.arrowImage.up
        let heightConstraint = tableView.constraints.first { $0.identifier == cstHeightIdentifier }
        heightConstraint?.constant = configuration.menuHeight
        UIView.animate(withDuration: configuration.animationDuration * 1.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .curveEaseOut,
                       animations: {
            self.menuView.layoutIfNeeded()
        }, completion: { _ in
            self.isAnimate = false
        })

        UIView.animate(withDuration: configuration.animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
            self.backgroundView.alpha = self.configuration.maskBackgroundAlpha
        })
    }
    
    private func hideDropDown() {
        if isAnimate { return }
        isAnimate = true
        imageArrow.image = configuration.arrowImage.down
        let heightConstraint = tableView.constraints.first { $0.identifier == cstHeightIdentifier }
        heightConstraint?.constant = 0
        UIView.animate(withDuration: configuration.animationDuration * 1.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .curveEaseOut,
                       animations: {
            self.menuView.layoutIfNeeded()
        }, completion: { _ in
            self.isAnimate = false
            self.menuView.isHidden = true
        })
        
        UIView.animate(withDuration: configuration.animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
            self.backgroundView.alpha = 0
        })
    }
    
    private func updateTitle(string: String) {
        lblTitle.text = string
    }
}

extension NVDropDownView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.nvTableView(self.tableView, numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource?.nvTableView(self.tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.nvTableView(self.tableView, didSelectRowAt: indexPath)
//        updateTitle(string: items[indexPath.row])
        hideDropDown()
        
    }
}

extension NVDropDownView {
    struct Configuration {
        var animationDuration: TimeInterval = 0.5
        var menuHeight: CGFloat = 300
        var arrowImage: (up: UIImage?, down: UIImage?) = (UIImage(named: "ic_arrow_up"), UIImage(named: "ic_arrow_down"))
        var title: Title = Title()
        var backgroundColor: UIColor = .white
        var maskBackgroundColor: UIColor = .black
        var maskBackgroundAlpha: CGFloat = 0.5
    }
    
    struct Title {
        var textAlignment: NSTextAlignment = .center
        var font: UIFont = UIFont.systemFont(ofSize: 20)
        var textColor: UIColor = .black
    }
}
