//
//  AppVersionAlertController.swift
//  SwiftX
//
//  Created by wangcong on 2019/4/11.
//

import UIKit

final class AppVersionAlertController: UIViewController {
    
    private static var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = true
        window.windowLevel = UIWindow.Level.statusBar + 0.01
        return window
    }()
    
    private lazy var opacityView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.01
        return view
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private var info: AppVersion.Info?

    override func viewDidLoad() {
        super.viewDidLoad()

        _initUI()
    }
    
}

extension AppVersionAlertController {
    
    private func _initUI() {
        opacityView.frame = UIScreen.main.bounds
        opacityView.alpha = 0.01
        view.addSubview(opacityView)
        
        let margin: CGFloat = 30
        let size = CGSize(width: UIScreen.width - 2 * margin, height: (UIScreen.width - 2 * margin) * 1018 / 855)
        infoView.frame = CGRect(origin: CGPoint(x: margin, y: (UIScreen.height - size.height) / 2.0), size: size)
        view.addSubview(infoView)
        
        let imageView = UIImageView(image: UIImage(named: "bg_version", in: Bundle(for: self.classForCoder), compatibleWith: nil))
        imageView.frame = infoView.bounds
        infoView.addSubview(imageView)
        
        let button0 = UIButton(type: .custom)
        button0.frame = CGRect(x: 15, y: 40, width: 44, height: 44)
        button0.tag = 0
        button0.setImage(UIImage(named: "icon_version_close", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        button0.addTarget(self, action: #selector(_buttonAction(_:)), for: .touchUpInside)
        infoView.addSubview(button0)
        
        let button1 = UIButton(type: .custom)
        button1.frame = CGRect(x: 20, y: infoView.height - 44 - 20, width: infoView.width - 40, height: 44)
        button1.tag = 1
        button1.setTitle("去更新", for: .normal)
        button1.setTitleColor(UIColor(hexColor: "#66B30C"), for: .normal)
        button1.clipsToBounds = true
        button1.layer.cornerRadius = 5
        button1.layer.borderWidth = 1.0
        button1.layer.borderColor = UIColor(hexColor: "#66B30C").cgColor
        button1.addTarget(self, action: #selector(_buttonAction(_:)), for: .touchUpInside)
        infoView.addSubview(button1)
        
        if let reloeaseNotes = info?.releaseNotes {
            let releaseNotesLabel = UILabel()
            releaseNotesLabel.text = reloeaseNotes
            releaseNotesLabel.textColor = UIColor(hexColor: "#333333")
            releaseNotesLabel.textAlignment = .left
            releaseNotesLabel.font = UIFont.systemFont(ofSize: 15)
            releaseNotesLabel.numberOfLines = 0
            let textHeight = reloeaseNotes.heightWith(font: releaseNotesLabel.font, limitWidth: infoView.width - 40)
            releaseNotesLabel.frame = CGRect(x: button1.x, y: (infoView.height - textHeight) / 2.0 + 30, width: infoView.width - button1.x * 2, height: textHeight + 5)
            infoView.addSubview(releaseNotesLabel)
        }
        
    }
    
    @objc private func _buttonAction(_ sender: UIButton) {
        _dismiss()
        if sender.tag == 1, let trackUrl = info?.trackViewUrl, let url = URL(string: trackUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func _show() {
        AppVersionAlertController.window.rootViewController = self
        AppVersionAlertController.window.makeKeyAndVisible()
        AppVersionAlertController.window.isHidden = false
        opacityView.alpha = 0.01
        infoView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.25) {
            self.opacityView.alpha = 0.7
            self.infoView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    private func _dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 0.01
            self.infoView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (finish) in
            AppVersionAlertController.window.isHidden = true
            AppVersionAlertController.window.rootViewController = nil
            AppVersionAlertController.window.removeFromSuperview()
        }
    }
    
}

extension AppVersionAlertController {
    
    static func show(info: AppVersion.Info) {
        let vc = AppVersionAlertController()
        vc.info = info
        vc._show()
    }
    
}
