//
//  Kernel.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 23/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import Metal

protocol Kernel {
    var functionName: String { get }
    func operation(encoder: MTLComputeCommandEncoder)
}
