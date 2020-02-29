//
//  BrithnessKernel.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 23/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import Metal

struct BrightnessKernel: Kernel {
    struct Brightness {
        let brithness: Float
    }
    var brightness: Float
    let pipelineStateRepository: PipelineStateRepository
    private let functionName = "brithnessAdjustment"

    init(pipelineStateRepository: PipelineStateRepository = .shared, brightness: Float) {
        self.pipelineStateRepository = pipelineStateRepository
        self.brightness = brightness
    }

    func operation(encoder: MTLComputeCommandEncoder) {
        var brightness = Brightness(brithness: self.brightness)
        encoder.setBytes(&brightness, length: MemoryLayout<Float>.stride, index: 0)
    }

    func computedPipelineState(from library: MTLLibrary, using device: MTLDevice) -> MTLComputePipelineState? {
        if let pipelineState = pipelineStateRepository.get(for: functionName) {
            return pipelineState
        }
        guard let function = library.makeFunction(name: functionName),
            let pipelineState = try? device.makeComputePipelineState(function: function) else {
            return nil
        }
        pipelineStateRepository.set(for: functionName, pipelineState: pipelineState)
        return pipelineState
    }
}

