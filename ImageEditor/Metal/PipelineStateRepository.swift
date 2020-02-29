//
//  PipelineStateRepository.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 27/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import Metal

class PipelineStateRepository {
    static let shared = PipelineStateRepository()

    private var pipelineStates: [String: MTLComputePipelineState] = [:]

    func get(for name: String) -> MTLComputePipelineState? {
        return pipelineStates[name]
    }

    func set(for name: String, pipelineState: MTLComputePipelineState) {
        pipelineStates[name] = pipelineState
    }
}
