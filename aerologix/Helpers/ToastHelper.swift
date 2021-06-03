//
//  ToastHelper.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//

import UIKit

func showToast(_ message : String?, textColor: UIColor = .white, bgColor: UIColor = .systemRed) {
    DispatchQueue.main.async {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        guard let window = sceneDelegate.window else { return }
        let messageLbl = UILabel()
        messageLbl.textAlignment = .center
        messageLbl.textColor = textColor
        messageLbl.backgroundColor = bgColor
        messageLbl.font = UIFont.preferredFont(forTextStyle: .body)
        messageLbl.text = message
        messageLbl.numberOfLines = 0
        messageLbl.alpha = 1
        messageLbl.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: CGFloat.greatestFiniteMagnitude)
        messageLbl.sizeToFit()
        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 60)
        messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: messageLbl.frame.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = 10
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            UIView.animate(withDuration: 2.0, animations: {
                messageLbl.alpha = 0
            }) { (_) in
                messageLbl.removeFromSuperview()
            }
        }
    }
}
