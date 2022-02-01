//
//  DropdownView.swift
//  DropdownView
//
//  Created by boicomp21070029 on 11/1/2565 BE.
//

import UIKit

protocol DropdownViewDelegate: AnyObject {
    func dropDownView(_ dropDownView: DropdownView, didSelectRowAt index: Int)
}

protocol DropdownViewDataSource: AnyObject {
    func numberOfRows(in dropDownView: DropdownView) -> Int
    func dropDownView(_ dropDownView: DropdownView, cellForRowAt index: Int) -> UITableViewCell?
}

final class DropdownView: UIView {
    //MARK: - DataSource, Delegate
    weak var delegate: DropdownViewDelegate?
    weak var dataSource: DropdownViewDataSource? {
        didSet {
            if adjustHeightMode == .automatic {
                automaticAdjustHeight()
                return
            }
            reloadData()
        }
    }
    
    //MARK: - Override Propeties
    override var backgroundColor: UIColor? {
        get {
            return tableView.backgroundColor
        }
        set {
            tableView.backgroundColor = newValue
        }
    }
    
    //MARK: - Public Properties
    /// Mode to adjust height
    /// - Parameter automatic: View will be have a height equal to contentSize if maximumHeight more than ContentSize, If not the view's height will be equal to maximumHeight.
    /// - Parameter none: View will be have a height equal to maximumHeight but if View has off-screen, It will be automatic adjust it fit to the sceen.
    var adjustHeightMode: AdjustMode = .automatic
    
    /// Mode to adjust width.
    /// - Parameter automatic: View will be have a width equal to anchorView.
    /// - Parameter none: View will be have width equal to maximumWidth but if View has off-screen, It will be automatic adjust it fit to the sceen.
    var adjustWidthMode: AdjustMode = .automatic
    var maximumHeight: CGFloat = 0 {
        didSet {
            constraintHeight.constant = maximumHeight
        }
    }
    var maximumWidth: CGFloat {
        get {
            return frame.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    /// The view's stick dropdown
    var anchorView: UIView! {
        didSet {
            observation = anchorView.observe(\.center, options: .new) { [weak self] view, _ in
                guard let self = self else { return }
                self.findSuperView(view: view)
                if self.adjustWidthMode == .automatic {
                    self.maximumWidth = view.bounds.width
                }
            }
            self.findSuperView(view: anchorView)
        }
    }
    
    var animate = true
    var animationOption: AnimationOption = .slide
    var duration: TimeInterval = 0.35
    var isAnimate = false
    
    //MARK: - Private Properties
    private(set) var isShown = false
    private(set) var appearance = Appearance()
    private var constraintHeight: NSLayoutConstraint!
    private var observation: NSKeyValueObservation?
    private let defaultCellIdentifier = "default_bhp_dropdown_cell"
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.contentInset = .zero
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
        return tableView
    }()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observation?.invalidate()
    }
    
    //MARK: - Configuration
    func configureView() {
        isHidden = true
        backgroundColor = .white
        appearance = Appearance(view: self, tableView: tableView)
    }
    
    func configureConstraint() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        constraintHeight = tableView.heightAnchor.constraint(equalToConstant: maximumHeight)
        constraintHeight.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
   
}

//MARK: - Adjust
extension DropdownView {
    private func findSuperView(view: UIView) {
        guard let superView = view.superview, superView != superview else {
            setOriginPoint(by: view.superview == nil ? view : view.superview!)
            return
        }
        
        findSuperView(view: superView)
    }

    private func setOriginPoint(by superView: UIView) {
        let convertFrame = anchorView.convert(anchorView.bounds, to: superView)
        let newOrigin = CGPoint(x: convertFrame.minX, y: convertFrame.maxY)
        frame.origin = newOrigin
        
        adjustSizeToFitScreen()
    }
    
    private func adjustSizeToFitScreen() {
        let diffX = frame.maxX - UIScreen.main.bounds.maxX
        let diffY = constraintHeight.constant - UIScreen.main.bounds.maxY
        
        if diffX > 0 {
            maximumWidth = frame.width - diffX
        }
        
        if diffY > 0 {
            maximumHeight = constraintHeight.constant - diffY
        }
    }

    private func automaticAdjustHeight() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            tableView.reloadData()
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else { return }
            let contentHeight = cell.frame.height * CGFloat(numberOfRows)
            if contentHeight > 0 && contentHeight < maximumHeight {
                maximumHeight = contentHeight
            }
        }
    }
}

//MARK: - Appearance
extension DropdownView {
    enum AnimationOption {
        case fade
        case slide
    }
    
    enum AdjustMode {
        case automatic
        case never
    }
    
    struct Appearance {
        var view: UIView!
        var tableView: UIView!
        
        var cornerRadius: CGFloat {
            get {
                return tableView.layer.cornerRadius
            }
            set {
                tableView.layer.cornerRadius = newValue
            }
        }
        var borderWidth: CGFloat {
            get {
                return tableView.layer.borderWidth
            }
            set {
                tableView.layer.borderWidth = newValue
            }
        }
        var borderColor: CGColor? {
            get {
                return tableView.layer.borderColor
            }
            set {
                tableView.layer.borderColor = newValue
            }
        }
        var shadowRadius: CGFloat {
            get {
                return view.layer.shadowRadius
            }
            set {
                view.layer.shadowRadius = newValue
            }
        }
        var shadowColor: CGColor? {
            get {
                return view.layer.shadowColor
            }
            set {
                view.layer.shadowColor = newValue
            }
        }
        var shadowOpacity: Float {
            get {
                return view.layer.shadowOpacity
            }
            set {
                view.layer.shadowOpacity = newValue
            }
        }
        var shadowOffset: CGSize {
            get {
                return view.layer.shadowOffset
            }
            set {
                view.layer.shadowOffset = newValue
            }
        }
        
        func addCornerRadius(radius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .clear) {
            tableView.layer.cornerRadius = radius
            tableView.layer.borderWidth = borderWidth
            tableView.layer.borderColor = borderColor.cgColor
            tableView.layer.masksToBounds = true
        }
        
        func addShadow(radius: CGFloat, color: UIColor = .black, opacity: Float = 0.5, offset: CGSize = .zero) {
            view.layer.shadowRadius = radius
            view.layer.shadowColor = color.cgColor
            view.layer.shadowOpacity = opacity
            view.layer.shadowOffset = offset
        }
    }
}


//MARK: - Animate Show/Hide
extension DropdownView {
    func toggle() {
        if !isShown {
            show()
        } else {
            hide()
        }
    }
    
    func show() {
        if anchorView == nil { return }
        isShown = true
        if let superView = superview {
            superView.bringSubviewToFront(self)
        }
        
        if animate {
            isAnimate = true
            switch animationOption {
            case .slide:
                showWithSlideAnimation()
            case .fade:
                showWithFadeAnimation()
            }
        } else {
            showWithoutAnimation()
        }
    }
    
    func hide() {
        if anchorView == nil { return }
        isShown = false
        if let superView = superview {
            superView.sendSubviewToBack(self)
        }
        if animate {
            switch animationOption {
            case .slide:
                hideWithSlideAnimation()
            case .fade:
                hideWithFadeAnimation()
            }
        } else {
            hideWithoutAnimation()
        }
    }
    
    private func showWithoutAnimation() {
        isHidden = false
        frame.size.height = maximumHeight
    }
    
    private func hideWithoutAnimation() {
        isHidden = true
    }
    
    private func showWithSlideAnimation() {
        isHidden = false
        frame.size.height = 0
        constraintHeight.constant = maximumHeight
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.frame.size.height = self.maximumHeight
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.isAnimate = false
        }
    }
    
    private func hideWithSlideAnimation() {
        constraintHeight.constant = 0
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.frame.size.height = 0
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.isHidden = true
        }
    }
    
    private func showWithFadeAnimation() {
        isHidden = false
        frame.size.height = maximumHeight
        constraintHeight.constant = maximumHeight
        alpha = 0
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.isAnimate = false
        }
    }
    
    private func hideWithFadeAnimation() {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.isHidden = true
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension DropdownView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfRows(in: self) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSource?.dropDownView(self, cellForRowAt: indexPath.row) ?? defaultCell(for: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.dropDownView(self, didSelectRowAt: indexPath.row)
    }
}



//MARK: - TableView Method
extension DropdownView {
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell(withIdentifier identifier: String, for index: Int) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(row: index, section: 0))
    }
    
    func cellForRow(at index: Int) -> UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: index, section: 0))
    }
    
    func defaultCell(for index: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: IndexPath(row: index, section: 0))
        cell.selectionStyle = .none
        return cell
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func reloadData(at index: Int, with animation: UITableView.RowAnimation) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: animation)
    }
}
