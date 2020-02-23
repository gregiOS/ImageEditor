//
//  BrithnessKernel.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 23/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import Metal

struct Brithness {
  let brithness: Float
}

struct BrithnessKernel: Kernel {
    var brithness: Float = 0
    let functionName = "brithnessAdjustment"


    func operation(encoder: MTLComputeCommandEncoder) {
        var brithness = Brithness(brithness: self.brithness)
        encoder.setBytes(&brithness, length: MemoryLayout<Float>.stride, index: 0)
    }
}

