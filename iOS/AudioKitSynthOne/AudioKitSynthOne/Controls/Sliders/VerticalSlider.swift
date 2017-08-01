//
//  VerticalSlider.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/11/16.
//  Copyright (c) 2016 AudioKit. All rights reserved.


import UIKit

@IBDesignable
class VerticalSlider: UIControl {
    
    public typealias VerticalSliderCallback = (Double) -> Void
    var callback: VerticalSliderCallback = { _ in }
    
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    var currentValue: CGFloat = 0.5 {
        didSet {
            if currentValue < minValue {
                currentValue = minValue
            }
            if currentValue > maxValue {
                currentValue = maxValue
            }
            self.sliderValue = CGFloat((currentValue - minValue) / (maxValue - minValue))
            setupView()
        }
    }
    
    let knobSize = CGSize(width: 40, height: 28)
    let barMargin: CGFloat = 20.0
    var knobRect: CGRect!
    var barLength: CGFloat = 132.0
    var isSliding = false
    var sliderY: CGFloat = 0.0
    var sliderValue: CGFloat = 0.5 {
        didSet {
            sliderY = convertValueToY(currentValue) - knobSize.height/2
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }
    
    class override var requiresConstraintBasedLayout : Bool {
        return true
    }
}

// MARK: - Lifecycle
extension VerticalSlider {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        knobRect = CGRect(x: 0, y: sliderY, width: knobSize.width, height: knobSize.height)
        barLength = bounds.height - (barMargin * 2)
    }
    
    override func draw(_ rect: CGRect) {
        SliderStyleKit.drawVerticalSlider(sliderY: sliderY)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}

// MARK: - Helpers
extension VerticalSlider {
    func convertYToValue(_ y: CGFloat) -> CGFloat {
        let offsetY = bounds.height - barMargin - y
        let value = (offsetY * maxValue) / barLength
        return value
    }
    
    func convertValueToY(_ value: CGFloat) -> CGFloat {
        let rawY = (value * barLength) / maxValue
        let offsetY = bounds.height - barMargin - rawY
        return offsetY
    }
    
    func transposeAmt(_ value: CGFloat) -> Double {
        return Double.scaleRange(Double(value), rangeMin: -12, rangeMax: 12)
    }
}

// MARK: - Control Touch Handling
extension VerticalSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if knobRect.contains(touch.location(in: self)) {
            isSliding = true
        }
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let rawY = touch.location(in: self).y
        
        if isSliding {
            let value = convertYToValue(rawY)
            currentValue = value
            callback(transposeAmt(currentValue))
            self.setNeedsDisplay()
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isSliding = false
    }
    
}
