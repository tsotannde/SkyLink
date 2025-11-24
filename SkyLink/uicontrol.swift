//
//  uicontrol.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/23/25.
//


import UIKit

//  Adds a press/tap animation to any UIControl (e.g., UIButton).
//  Usage: myButton.addCoolTapFeature()
extension UIControl
{
   func addPressAnimation(duration: TimeInterval = 0.2, scaleFactor: CGFloat = 0.95)
   {
       let originalTransform = self.transform
       
       self.addAction(UIAction { [weak self] _ in
           guard let self = self else { return }
           UIView.animate(withDuration: duration, animations:{self.transform = originalTransform.scaledBy(x: scaleFactor, y: scaleFactor)})}, for: .touchDown)
       
       self.addAction(UIAction { [weak self] _ in
           guard let self = self else { return }
           UIView.animate(withDuration: duration, animations: {self.transform = originalTransform})}, for: [.touchUpInside, .touchUpOutside, .touchCancel])
   }
}
