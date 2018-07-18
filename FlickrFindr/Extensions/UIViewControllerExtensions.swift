//
//  UIViewControllerExtensions.swift
//  FlickrFindr
//
//  Created by Manjunath Chandrashekar on 18/07/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func alert(title: String, message: String, buttonTitle: String) -> Void {
        let alert = UIAlertController.init(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        let action = UIAlertAction.init(title: buttonTitle,
                                        style: .default,
                                        handler: { (action) in
                                            alert.dismiss(animated: true)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func makeToast(backgroundColor:UIColor, textColor:UIColor, message:String) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: "", size: 15)
        label.adjustsFontSizeToFitWidth = true
        
        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR
        
        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.darkGray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.frame = CGRect(x: 0, y: 0, width: appDelegate.window!.frame.size.width, height: 44)
        
        label.alpha = 1
        
        appDelegate.window!.addSubview(label)
        
        var basketTopFrame: CGRect = label.frame;
        basketTopFrame.origin.y = 64;
        
        UIView.animate(withDuration :2.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.25,
                       options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                        label.frame = basketTopFrame
        }, completion: { (value: Bool) in
            UIView.animate(withDuration:2.0,
                           delay: 2.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.25,
                           options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                            label.alpha = 0
            },  completion: {
                (value: Bool) in
                label.removeFromSuperview()
            })
        })
    }
    
    func showToast(success message:String) {
        DispatchQueue.main.async {
            self.makeToast(backgroundColor: .green, textColor: .lightText, message: message)
        }
    }
    
    func showToast(error message:String) {
        DispatchQueue.main.async {
            self.makeToast(backgroundColor: .red, textColor: .lightText, message: message)
        }
    }
    
}

