//
//  CHIPageControlJaloro.swift
//  CHIPageControl  ( https://github.com/ChiliLabs/CHIPageControl )
//
//  Copyright (c) 2017 Chili ( http://chi.lv )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

open class CHIPageControlJaloro: CHIBasePageControl {

    @IBInspectable open var elementWidth: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var elementHeight: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }

    fileprivate var inactive = [CHILayer]()
    fileprivate var active = CHILayer()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func updateNumberOfPages(_ count: Int) {
        inactive.forEach { $0.removeFromSuperlayer() }
        inactive = [CHILayer]()
        inactive = (0..<count).map {_ in
            let layer = CHILayer()
            self.layer.addSublayer(layer)
            return layer
        }

        self.layer.addSublayer(active)

        setNeedsLayout()
        self.invalidateIntrinsicContentSize()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let floatCount = CGFloat(inactive.count)
        let x = (self.bounds.size.width - self.elementWidth*floatCount - self.padding*(floatCount-1))*0.5
        let y = (self.bounds.size.height - self.elementHeight)*0.5
        var frame = CGRect(x: x, y: y, width: self.elementWidth, height: self.elementHeight)

        active.cornerRadius = self.radius
        active.backgroundColor = (self.currentPageTintColor ?? self.tintColor)?.cgColor
        active.frame = frame

        inactive.enumerated().forEach() { index, layer in
            layer.backgroundColor = self.tintColor(position: index).withAlphaComponent(self.inactiveTransparency).cgColor
            if self.borderWidth > 0 {
                layer.borderWidth = self.borderWidth
                layer.borderColor = self.tintColor(position: index).cgColor
            }
            layer.cornerRadius = self.radius
            layer.frame = frame
            frame.origin.x += self.elementWidth + self.padding
        }
        update(for: progress)
    }

    override func update(for progress: Double) {
        guard let min = inactive.first?.frame,
              let max = inactive.last?.frame,
              progress >= 0 && progress <= Double(numberOfPages - 1),
              numberOfPages > 1 else {
                return
        }

        let total = Double(numberOfPages - 1)
        let dist = max.origin.x - min.origin.x
        let percent = CGFloat(progress / total)

        let offset = dist * percent
        active.frame.origin.x = min.origin.x + offset
        
        // keep active color when move to next step
        inactive.enumerated().forEach() { index, layer in
            let color = index <= Int(progress) ? (self.currentPageTintColor ?? self.tintColor)?.cgColor : self.tintColor(position: index).withAlphaComponent(self.inactiveTransparency).cgColor
            layer.backgroundColor = color
        }
    }

    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactive.count) * self.elementWidth + CGFloat(inactive.count - 1) * self.padding,
                      height: self.elementHeight)
    }

    override open func didTouch(gesture: UITapGestureRecognizer) {
        let point = gesture.location(ofTouch: 0, in: self)
        if let touchIndex = inactive.enumerated().first(where: { $0.element.hitTest(point) != nil })?.offset {
            delegate?.didTouch(pager: self, index: touchIndex)
        }
    }
}
