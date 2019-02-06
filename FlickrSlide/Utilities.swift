//
//  Utilities.swift
//  FlickrSlide
//
//  Created by Xeon on 06/02/2019.
//  Copyright © 2019 Xeon. All rights reserved.
//

import Foundation

struct AnonymousError: Error {}

extension Optional {
    func unwrapped() throws -> Wrapped  {
        if let `self` = self {
            return self
        } else {
            throw AnonymousError()
        }
    }
}

extension String {
    var iso8601DateTime: Date? {
        let df = DateFormatter()
        
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //ISO 8601 date string
        df.timeZone = TimeZone(identifier: "UTC")
        
        return df.date(from: self)
    }
}

import RxSwift

extension ObservableConvertibleType {
    func mapSwitch<T>(_ transform: @escaping (Self.E) -> T) -> Observable<T.E> where T: ObservableConvertibleType {
        return self.asObservable()
            .map { transform($0).asObservable() }
            .switchLatest()
    }
}

extension ObservableConvertibleType {
    func setMinimumDelay(_ delay: Double) -> Observable<Self.E> {
        
        let delayedSignal: Observable<Void> = Observable.concat(
            Observable<Int>.timer(delay, scheduler: MainScheduler.instance).map { _ in },
            Observable.of((1...)).map { _ in }
        )

        return Observable<Self.E>.zip(
            self.asObservable(),
            delayedSignal,
            resultSelector: { (item, _) in item }
        )
    }
}
