//
//  BigImageView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/15.
//

import UIKit
import SnapKit

class BigImageView: UIView {
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    class func show(load: (_ imageView: UIImageView) -> Void) {
        let view = BigImageView()
        load(view.imageView)
        UIApplication.shared.keyWindow?.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selfInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.scrollView.bounds
    }
    
    private func selfInit() {
        self.backgroundColor = UIColor(named: ColorName_181818)
        self.scrollView.zoomScale = 1
        self.scrollView.maximumZoomScale = 3
        self.scrollView.minimumZoomScale = 1
        self.scrollView.isMultipleTouchEnabled = true
        self.scrollView.delegate = self
        self.imageView.contentMode = .scaleAspectFit
        
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(tap:)))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
    }
    
    @objc private func onTap(tap: UITapGestureRecognizer) {
        if tap.numberOfTapsRequired == 1 {
            self.removeFromSuperview()
        } else {
            UIView.animate(withDuration: 0.3) {
                self.scrollView.zoomScale = 1
            }
        }
    }
}

extension BigImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale < 1 {
            self.scrollView.zoomScale = 1
        }
    }
}
