//
//  Renderer.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 16/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class TextureRenderer {
    let device: MTLDevice
    let library: MTLLibrary
    let commandQueue: MTLCommandQueue

    var brithness: Float = 0

    init(device: MTLDevice) throws {
        guard let libraryPath = Bundle.main.path(forResource: "default", ofType: "metallib") else {
            throw Error.libraryNotExists
        }

        self.device = device
        self.library = try device.makeLibrary(filepath: libraryPath)
        self.commandQueue = device.makeCommandQueue()!
    }

    func apply(kernel: Kernel, inTexture: MTLTexture, into drawable: CAMetalDrawable) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }

        let outTexture = drawable.texture

        let threads = makeThreadgroups(textureWidth: outTexture.width, textureHeight: outTexture.height)

        guard let kernelFunction = library.makeFunction(name: kernel.functionName),
            let pipelineState = try? device.makeComputePipelineState(function: kernelFunction) else {
            // todo: handle optional
            return
        }

        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(inTexture, index: 0)
        commandEncoder.setTexture(outTexture, index: 1)

        kernel.operation(encoder: commandEncoder)

        commandEncoder.dispatchThreadgroups(threads.threadgroupsPerGrid, threadsPerThreadgroup: threads.threadsPerThreadgroup)
        commandEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private
    func makeThreadgroups(textureWidth: Int, textureHeight: Int) -> (threadgroupsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize) {
        let threadSize = 16
        let threadsPerThreadgroup = MTLSizeMake(threadSize, threadSize, 1)
        let horizontalThreadgroupCount = textureWidth / threadsPerThreadgroup.width + 1
        let verticalThreadgroupCount = textureHeight / threadsPerThreadgroup.height + 1
        let threadgroupsPerGrid = MTLSizeMake(horizontalThreadgroupCount, verticalThreadgroupCount, 1)

        return (threadgroupsPerGrid: threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}

extension TextureRenderer {
    enum Error: Swift.Error {
        case libraryNotExists
        case functionNotFound
        case deviceNotExists
    }
}
