//
//  SlidingViewController.swift
//  FlickrSlide
//
//  Created by Xeon on 06/02/2019.
//  Copyright © 2019 Xeon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SlidingViewController: UIViewController {
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var button: UIButton!
    
    var imageSlidingInterval: Double! //injected
    var completion: (() -> Void)! //injected
    
    static private let feedRefreshInterval: Double = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageSlidingInterval = self.imageSlidingInterval!
        
        let initialLoadingView = UIActivityIndicatorView(style: .whiteLarge)
        initialLoadingView.startAnimating()
        
        Observable<Int>.timer(0.0, period: SlidingViewController.feedRefreshInterval, scheduler: MainScheduler.instance)
            .map { _ in }
            .mapSwitch {
                return FlickerImages().getResult()
                    .catchError { _ in Observable.empty() }
            }
            .distinctUntilChanged { $0.updated == $1.updated }
            .mapSwitch { (results) -> Observable<UIImage> in
                let imageFetcher = ImageFetcher(imageSlidingInterval: imageSlidingInterval)
                return imageFetcher.getImages(imageURLs: results.imageURLs)
            }
            .map { image -> UIView in
                return UIView.generateFromImage(image: image)
            }
            .takeUntil(self.rx.deallocated)
            .startWith(initialLoadingView)
            .mapSwitch { [unowned self] content -> Observable<Void> in
                return self.contentsView.viewSliding(content: content)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem!.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.completion()
            })
            .disposed(by: disposeBag)
        
        button.rx.tap.asObservable()
            .enumerated()
            .map { index, _ in index%2 == 0 }
            .subscribe(onNext: { [unowned self] (hidden) in
                self.navigationController?.setNavigationBarHidden(hidden, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private let disposeBag = DisposeBag()
}

