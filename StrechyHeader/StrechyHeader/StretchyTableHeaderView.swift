//
//  StretchyTableHeaderView.swift
//  StrechyHeader
//
//  Created by boicomp21070029 on 19/12/2564 BE.
//

import UIKit

final class StretchyTableHeaderView: UIView, UIScrollViewDelegate {
    private lazy var imageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.contentMode = .scaleAspectFill
        uiImageView.image = UIImage(named: "img_header")
        uiImageView.clipsToBounds = true
        return uiImageView
    }()
    
    private lazy var label: UILabel = {
        let uiLabel = UILabel()
        uiLabel.textAlignment = .center
        uiLabel.textColor = .white
        uiLabel.text = "Header"
        uiLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return uiLabel
    }()
    
    private var imvConstraintTop = NSLayoutConstraint()
    
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(imageView)
        imageView.addSubview(label)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
        imvConstraintTop = imageView.topAnchor.constraint(equalTo: topAnchor)
        imvConstraintTop.isActive = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imvConstraintTop.constant = min(-scrollView.adjustedContentInset.top, scrollView.contentOffset.y)
    }
}
