//
//  VMapBottomToolView.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import UIKit
import SnapKit

fileprivate let kContentHeight = 180.0 + bottomSafeHeight

enum VMapState {
    case destination
    case navigation
    case overview
}

class VMapBottomToolView: UIView {
    public weak var delegate: VMapBottomToolViewDelegate?
    public var type: VMapState = .destination {
        didSet {
            updateInfo()
        }
    }
    
    lazy var containView = UIView()
    lazy var placeLabel = UILabel()
    lazy var descLabel = UILabel()
    lazy var driveIcon = UIImageView()
    lazy var timeLabel = UILabel()
    
    var closeButton: UIButton!
    var firstButton: UIButton!
    var secondButton: UIButton!
    
    // MARK: - Action
    @objc func closeDidClick() {
        switch self.type {
        case .navigation:
            self.delegate?.exitNavigation()
        default:
            self.delegate?.cleanDidClick()
        }
    }
    
    @objc func firstButtonDidClick() {
        if self.firstButton.isSelected {
            self.delegate?.switchNavigationView()
        } else {
            self.delegate?.directionsDidClick()
        }
    }
    
    @objc func secondButtonDidClick() {
        if self.secondButton.isSelected {
            self.delegate?.exitNavigation()
        } else {
            self.delegate?.startNavigation()
        }
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

extension VMapBottomToolView {
    public func clean() {
        updateTime(nil)
        descLabel.text = nil
        placeLabel.text = nil
    }
    
    public func updateTime(_ text: String?) {
        if let time = text {
            self.driveIcon.isHidden = false
            self.timeLabel.text = time
        } else {
            self.driveIcon.isHidden = true
        }
    }
    
    public func showContainView() {
        self.isHidden = false
        self.updateInfo()
        self.containView.transform = CGAffineTransform(translationX: 0, y: kContentHeight)
        UIView.animate(withDuration: 0.25) {
            self.containView.transform = .identity
        }
    }
    
    public func hiddenContainView() {
        UIView.animate(withDuration: 0.1) {
            self.containView.transform = CGAffineTransform(translationX: 0, y: kContentHeight)
        } completion: { _ in
            self.isHidden = true
        }
    }
}

extension VMapBottomToolView {
    private func setupUI() {
        self.backgroundColor = .clear
        self.isHidden = true
        
        containView.backgroundColor = .white
        containView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containView.layer.cornerRadius = 10
        containView.frame = CGRect(
            x: 0, y: 0,
            width: kScreenWidth,
            height: kContentHeight
        )
        
        addSubview(containView)
        closeButton = UIButton(type: .custom)
        closeButton.setImage("vmap_icon_close".image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeDidClick), for: .touchUpInside)
        closeButton.frame = CGRect(
            x: kScreenWidth - 34, y: 10,
            width: 24,
            height: 24
        )
        containView.addSubview(closeButton)
        
        placeLabel.font = .systemFont(ofSize: 18)
        placeLabel.textColor = .black
        placeLabel.frame = CGRect(
            x: 10, y: 20,
            width: kScreenWidth - 60,
            height: 22
        )
        containView.addSubview(placeLabel)
        
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .lightGray
        descLabel.frame = CGRect(
            x: 10, y: 47,
            width: kScreenWidth - 20,
            height: 18
        )
        containView.addSubview(descLabel)
        
        driveIcon.image = "vmap_icon_drive".image
        driveIcon.isHidden = true
        driveIcon.frame = CGRect(
            x: 10, y: 70,
            width: 15,
            height: 15
        )
        containView.addSubview(driveIcon)
        
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .lightGray
        timeLabel.frame = CGRect(
            x: 30, y: 68,
            width: 100,
            height: 19
        )
        containView.addSubview(timeLabel)
        
        firstButton = UIButton(type: .custom)
        firstButton.layer.cornerRadius = 22
        firstButton.backgroundColor = .blue
        firstButton.setTitle("Directions", for: .normal)
        firstButton.setTitle("Switch", for: .selected)
        firstButton.addTarget(self, action: #selector(firstButtonDidClick), for: .touchUpInside)
        let buttonWidth = (kScreenWidth - 30) * 0.5
        firstButton.frame = CGRect(
            x: 10, y: 100,
            width: buttonWidth,
            height: 44
        )
        containView.addSubview(firstButton)
        
        secondButton = UIButton(type: .custom)
        secondButton.layer.cornerRadius = 22
        secondButton.backgroundColor = .blue.withAlphaComponent(0.08)
        secondButton.setTitleColor(.blue, for: .normal)
        secondButton.setTitleColor(.blue, for: .selected)
        secondButton.setTitle("Start", for: .normal)
        secondButton.setTitle("Exit", for: .selected)
        secondButton.addTarget(self, action: #selector(secondButtonDidClick), for: .touchUpInside)
        secondButton.frame = CGRect(
            x: buttonWidth + 20, y: 100,
            width: buttonWidth,
            height: 44
        )
        containView.addSubview(secondButton)
    }
    
    private func updateInfo() {
        self.firstButton.isHidden = false
        self.secondButton.isHidden = false
        switch self.type {
        case .overview:
            self.firstButton.isHidden = true
            self.secondButton.isHidden = true
        case .navigation:
            self.firstButton.isSelected = true
            self.secondButton.isSelected = true
        default:
            self.firstButton.isSelected = false
            self.secondButton.isSelected = false
        }
    }
    
}
