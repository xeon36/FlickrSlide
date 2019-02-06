//
//  FlickerImages.swift
//  FlickrSlide
//
//  Created by Xeon on 06/02/2019.
//  Copyright © 2019 Xeon. All rights reserved.
//

import Foundation

struct FlickerImages {
    static let source = "https://api.flickr.com/services/feeds/photos_public.gne"
    
    struct Result {
        let imageURLs: [URL]
        let updated: Date
    }
}

import RxSwift
import SwiftyXML

extension FlickerImages {
    func getResult() -> Observable<Result> {
        return Observable.deferred {
            try Observable.just(String(contentsOf: URL(string: FlickerImages.source).unwrapped()))
            }
            .map { xmlString in
                let xml = XML(string: xmlString)
                
                let imageURLs = try xml["entry"]
                    .map { entries in
                        let links = entries["link"]
                        
                        let imageLinks = links.filter { $0["@type"].string == "image/jpeg" }
                        
                        let imageLinksHrefValue = imageLinks.first.flatMap { $0["@href"].string }
                        
                        return imageLinksHrefValue
                    }
                    .compactMap { $0 }
                    .map { try URL(string: $0).unwrapped() }
                
                let updated = try xml["updated"]
                    .string.unwrapped()
                    .iso8601DateTime.unwrapped()
                
                return Result(imageURLs: imageURLs, updated: updated)
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.userInitiated))
            .observeOn(MainScheduler.instance)
    }
}
