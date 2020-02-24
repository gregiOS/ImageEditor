//
//  ViewBuilder.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 24/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import UIKit

class ViewBuilder {
    static func make<T: UIView>(inside view: UIView, configure: ((T) -> Void)? = nil) -> T {
        let subview = T.init()
        subview.translatesAutoresizingMaskIntoConstraints = false
        configure?(subview)
        view.addSubview(subview)
        return subview
    }
}
