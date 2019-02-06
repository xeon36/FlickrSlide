//
//  ImageFetcher.swift
//  FlickrSlide
//
//  Created by Xeon on 06/02/2019.
//  Copyright © 2019 Xeon. All rights reserved.
//

import Foundation
import RxSwift

struct ImageFetcher {
    let imageSlidingInterval: Double
    
    func getImages(imageURLs: [URL]) -> Observable<UIImage> {
        let imageSlidingInterval = self.imageSlidingInterval
        
        let infiniteSource = (1...).lazy.flatMap { _ in imageURLs }
        
        let source = infiniteSource
            .enumerated()
            .lazy
            .map { index, imageUrl in
                return (imageUrl, (index == 0 ? Double.leastNormalMagnitude : imageSlidingInterval))
            }
            .map { imageURL, interval -> Observable<UIImage> in
                return Observable.deferred {
                    try Observable.just(UIImage(data: Data(contentsOf: imageURL)).unwrapped())
                    }
                    .setMinimumDelay(interval)
                    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.userInitiated))
                    .observeOn(MainScheduler.instance)
                    .catchError { _ in Observable.empty() }
            }
        
        return Observable.concat(source)
    }
}
