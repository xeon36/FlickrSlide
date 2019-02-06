//
//  MainViewController.swift
//  FlickrSlide
//
//  Created by Xeon on 31/01/2019.
//  Copyright © 2019 Xeon. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.rx.tap
            .asObservable()
            .mapSwitch { [unowned self] _ in
                Observable<Void>.create { (observer) -> Disposable in
                    let vc = (UIStoryboard(name: "Main", bundle: nil)
                        .instantiateViewController(withIdentifier: "SlidingViewController")
                        as! SlidingViewController)
                    vc.imageSlidingInterval = Double(self.slider.value)
                    vc.completion = {
                        observer.onNext(())
                        observer.onCompleted()
                    }
                    
                    self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
                    
                    return Disposables.create { [weak self] in
                        self?.dismiss(animated: true, completion:  nil)
                    }
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()
}

