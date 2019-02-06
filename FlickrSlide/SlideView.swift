//
//  SlideView.swift
//  FlickrSlide
//
//  Created by Xeon on 06/02/2019.
//  Copyright © 2019 Xeon. All rights reserved.
//

import UIKit
import RxSwift

extension UIView {
    func viewSliding(content: UIView) -> Observable<Void> {
        return Observable<Void>.create { (observer) -> Disposable in
            content.frame = self.bounds
            content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            content.translatesAutoresizingMaskIntoConstraints = true
            self.addSubview(content)
            self.sendSubviewToBack(content)
            content.alpha = 0.0

            UIView.animate(withDuration: 1.0, animations: {
                content.alpha = 1.0
            }, completion: { _ in
                
            })
            
            return Disposables.create {
                UIView.animate(withDuration: 1.0, animations: {
                    content.alpha = 0
                }, completion: { _ in
                    content.removeFromSuperview()
                })
            }
        }
    }
}

extension UIView {
    static func generateFromImage(image: UIImage) -> UIView {
        let content = UIImageView(frame: CGRect.zero)
        content.image = image
        content.contentMode = .scaleAspectFit
        return content
    }
}
