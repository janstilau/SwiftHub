//
//  SegmentedControl.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 6/30/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HMSegmentedControl

class SegmentedControl: HMSegmentedControl {
    
    // 响应式的方式, 使得各个部件, 成为了信号槽似的构建方式.
    /*
     BehaviorRelay, 必须设置初值, 后续的 Subscribe 会收到当前存储的值.
     这对 UI 的初始化是非常重要的, 使用这个机制, 可以让 UI 的初始化和后续更新, 都在统一的代码逻辑之中.
     */
    let segmentSelection = BehaviorRelay<Int>(value: 0)
    
    init() {
        super.init(sectionTitles: [])
        makeUI()
    }
    
    override init(sectionTitles sectiontitles: [String]) {
        super.init(sectionTitles: sectiontitles)
        makeUI()
    }
    
    override init(sectionImages: [UIImage], sectionSelectedImages: [UIImage]) {
        super.init(sectionImages: sectionImages, sectionSelectedImages: sectionSelectedImages)
        makeUI()
    }
    
    override init(sectionImages: [UIImage], sectionSelectedImages: [UIImage], titlesForSections sectionTitles: [String]) {
        super.init(sectionImages: sectionImages, sectionSelectedImages: sectionSelectedImages, titlesForSections: sectionTitles)
        makeUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    
    // 各种操作, 最终归结到一点.
    func makeUI() {
        
        /*
         themeService.typeStream 返回一个公用的信号源.
         响应式, 使得 数据改变 - 响应程序 之间的联系松散, 在各个业务模块中, 进行注册链接.
         */
        themeService.typeStream.subscribe(onNext: { [weak self] (themeType) in
            let theme = themeType.associatedObject
            self?.backgroundColor = theme.primary
            self?.selectionIndicatorColor = theme.secondary
            let font = UIFont.systemFont(ofSize: 11)
            self?.titleTextAttributes = [NSAttributedString.Key.font: font,
                                         NSAttributedString.Key.foregroundColor: theme.text]
            self?.selectedTitleTextAttributes = [NSAttributedString.Key.font: font,
                                                 NSAttributedString.Key.foregroundColor: theme.secondary]
            self?.setNeedsDisplay()
        }).disposed(by: rx.disposeBag)
        
        cornerRadius = Configs.BaseDimensions.cornerRadius
        imagePosition = .aboveText
        selectionStyle = .box
        selectionIndicatorLocation = .bottom
        selectionIndicatorBoxOpacity = 0
        selectionIndicatorHeight = 2.0
        segmentEdgeInset = UIEdgeInsets(inset: self.inset)
        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.segmentedControlHeight)
        }
        
        // 闭包改变之后, 是使用 Subject 进行信号的发射.
        // 使用 Subject, 从命令式的世界, 到达了响应式的世界. 
        indexChangeBlock = { [weak self] index in
            self?.segmentSelection.accept(Int(index))
        }
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
}
