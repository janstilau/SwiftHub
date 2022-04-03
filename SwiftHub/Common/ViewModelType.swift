//
//  ViewModelType.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 6/30/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

/*
 信号 Publisher, 会有一个组合的过程. 在该 App 里面, 将这个过程统一了.
 每一个 ViewModel, 都会提供一个 Transform, 按照自己的逻辑, 进行信号的加工处理. 
 */
protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output

    /*
     这个协议的作用, 就是添加了一个统一的方法, ViewModel 需要在这个方法里面, 进行信号的转换处理.
     各个 VC, 需要在 tranfrom 前组装自己的 Input 类型, 然后在自己的 ViewModel 里面进行转化, VC 则需要在转换后, 使用 output 进行业务逻辑的处理. 
     */
    func transform(input: Input) -> Output
}

class ViewModel: NSObject {

    let provider: SwiftHubAPI

    var page = 1

    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()

    let error = ErrorTracker()
    let serverError = PublishSubject<Error>()
    let parsedError = PublishSubject<ApiError>()

    init(provider: SwiftHubAPI) {
        self.provider = provider
        super.init()

        serverError.asObservable().map { (error) -> ApiError? in
            do {
                let errorResponse = error as? MoyaError
                if let body = try errorResponse?.response?.mapJSON() as? [String: Any],
                    let errorResponse = Mapper<ErrorResponse>().map(JSON: body) {
                    return ApiError.serverError(response: errorResponse)
                }
            } catch {
                print(error)
            }
            return nil
        }.filterNil().bind(to: parsedError).disposed(by: rx.disposeBag)

        /*
         直接在自己内部, 注册了错误处理.
         信号发射这种模型的好处, 就是监听这件事, 变的容易.
         不需要一个统一的入口, 来做分发这件事. 业务模块, 想要在信号发送的时候做一些事情, 在业务模块进行 Connect 就好了.
         */
        parsedError.subscribe(onNext: { (error) in
            logError("\(error)")
        }).disposed(by: rx.disposeBag)
    }
}
