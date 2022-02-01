//
//  BubbleTabBar.swift
//  BubbleTabBar
//
//  Created by Admin on 9/11/2564 BE.
//

import UIKit

final class BubbleTabBar: UITabBar {
    //MARK: - Properties
    //MARK: Override
    override var backgroundColor: UIColor? {
        get {
            return curveBackgroundColor
        }
        set {
            curveBackgroundColor = newValue
        }
    }
    
    //MARK: Public
    var animation = false
    var animateDuration: TimeInterval = 0.3
    var circleBackgroundColor: UIColor? = UIColor.white
    var radius: CGFloat {
        return (bounds.height - safeAreaInsets.bottom) * 0.65
    }
    
    //MARK: Private
    private var shapeLayer = CAShapeLayer()
    private var currentPath: CGPath? { didSet { previousPath = oldValue } }
    private var previousPath: CGPath?
    private var circleView = UIView()
    private var circleImageView = UIImageView()
    private var curveBackgroundColor: UIColor? = UIColor.white
    private var previousIndex = 0
    private var currentIndex = 0 {
        didSet {
            previousIndex = oldValue
            animateCircleView()
            setNeedsDisplay()
        }
    }
    private var sortSubViews: [UIView] {
        return subviews.filter({ $0 != circleView }).sorted(by: { $0.frame.minX < $1.frame.minX })
    }
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        initTabBar()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShapeLayout()
        updateCircleViewLayout()
    }
    
    private func initView() {
        layer.insertSublayer(shapeLayer, at: 0)
        addCircleView()
    }
    
    //MARK: - Method
    func selectedItem(at index: Int) {
        if index != currentIndex {
            currentIndex = index
        }
    }
}

//MARK: - Draw TabBar
extension BubbleTabBar {
    private func initTabBar() {
        currentPath = getPath(at: currentIndex)
        
        if animation {
            //Animate CircleView
            UIView.animate(withDuration: animateDuration,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                self.sortSubViews[self.currentIndex].alpha = 0
            },
                           completion: { _ in
                self.sortSubViews[self.currentIndex].isHidden = true
            })
            
            if previousIndex != currentIndex {
                sortSubViews[previousIndex].isHidden = false
                UIView.animate(withDuration: animateDuration,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                    self.sortSubViews[self.previousIndex].alpha = 1
                })
            }
            
            //Animate TabBar
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = previousPath
            animation.toValue = currentPath
            animation.duration = animateDuration
            animation.fillMode = .forwards
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.delegate = self
            shapeLayer.add(animation, forKey: "path")
        } else {
            sortSubViews[currentIndex].isHidden = true
            if previousIndex != currentIndex {
                sortSubViews[previousIndex].isHidden = false
            }
            shapeLayer.path = currentPath
        }
    }
    
    private func updateShapeLayout() {
        shapeLayer.path = getPath(at: currentIndex)
        shapeLayer.fillColor = curveBackgroundColor?.cgColor
    }
    
    private func getPath(at index: Int) -> CGPath? {
        let frame = sortSubViews[index].frame
        let path = UIBezierPath()
        let offset: CGFloat = 5
        let startPoint = CGPoint(x: frame.midX - radius - offset, y: 0)
        let endPoint = CGPoint(x: frame.midX + radius + offset, y: 0)
        path.move(to: .zero)
        path.addLine(to: startPoint)
        path.addCurve(to: CGPoint(x: frame.midX, y: radius),
                      controlPoint1: CGPoint(x: startPoint.x + offset, y: 0),
                      controlPoint2: CGPoint(x: startPoint.x + offset, y: radius))
        path.addCurve(to: endPoint,
                      controlPoint1: CGPoint(x: endPoint.x - offset, y: radius),
                      controlPoint2: CGPoint(x: endPoint.x - offset, y: 0))
        path.addLine(to: CGPoint(x: self.frame.maxX, y: 0))
        path.addLine(to: CGPoint(x: self.frame.maxX, y: self.frame.maxY))
        path.addLine(to: CGPoint(x: 0, y: self.frame.maxY))
        path.close()
        return path.cgPath
    }
}

//MARK: - Circle View
extension BubbleTabBar {
    private func addCircleView() {
        circleView.backgroundColor = circleBackgroundColor
        circleView.clipsToBounds = true

        circleView.addSubview(circleImageView)
        circleImageView.contentMode = .center
        circleImageView.image = items?[currentIndex].selectedImage
        
        circleImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleImageView.topAnchor.constraint(equalTo: circleView.topAnchor),
            circleImageView.bottomAnchor.constraint(equalTo: circleView.bottomAnchor),
            circleImageView.leftAnchor.constraint(equalTo: circleView.leftAnchor),
            circleImageView.rightAnchor.constraint(equalTo: circleView.rightAnchor)
        ])
        addSubview(circleView)
        bringSubviewToFront(circleView)
    }

    private func updateCircleViewLayout() {
        circleView.frame = getCircleViewFrame()
        circleView.layer.cornerRadius = circleView.bounds.height/2
    }

    private func animateCircleView() {
        if animation {
            UIView.animate(withDuration: animateDuration,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                self.circleView.frame = self.getCircleViewFrame()
            })
            
            UIView.animate(withDuration: animateDuration/2,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                self.circleImageView.alpha = 0
            },
                           completion: { _ in
                self.circleImageView.image = self.selectedItem?.selectedImage
                UIView.animate(withDuration: self.animateDuration/2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                    self.circleImageView.alpha = 1
                })
            })
        } else {
            circleView.frame = getCircleViewFrame()
            circleImageView.image = selectedItem?.selectedImage
        }
    }

    private func getCircleViewFrame() -> CGRect {
        let view = sortSubViews[currentIndex]
        let radius = self.radius * 0.85
        let size = CGSize(width: radius*2, height: radius*2)
        let origin = CGPoint(x: view.frame.midX - radius, y: -radius)
        return CGRect(origin: origin, size: size)
    }
}

extension BubbleTabBar: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            shapeLayer.path = currentPath
        }
    }
}
