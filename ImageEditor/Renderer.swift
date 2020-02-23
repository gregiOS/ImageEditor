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

struct Brithness {
  let brithness: Float
}

class TextureRenderer {
    let device: MTLDevice
    let library: MTLLibrary
    let commandQueue: MTLCommandQueue
    let computePipelineState: MTLComputePipelineState

    var brithness: Float = 0

    init(functionName: String) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw Error.deviceNotExists
        }

        guard let libraryPath = Bundle.main.path(forResource: "default", ofType: "metallib") else {
            throw Error.libraryNotExists
        }
        self.device = device
        self.library = try device.makeLibrary(filepath: libraryPath)
        self.commandQueue = device.makeCommandQueue()!

        guard let kernelFunction = library.makeFunction(name: functionName) else {
            throw Error.functionNotFound
        }

        self.computePipelineState = try device.makeComputePipelineState(function: kernelFunction)
    }

    func applyKernel(inTexture: MTLTexture, outTexture: MTLTexture, into drawable: CAMetalDrawable) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }

        let threads = makeThreadgroups(textureWidth: outTexture.width, textureHeight: outTexture.height)



        let drawwingTexture = drawable.texture

        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.setTexture(inTexture, index: 0)
        commandEncoder.setTexture(drawwingTexture, index: 1)

        var brithness = Brithness(brithness: self.brithness)
        commandEncoder.setBytes(&brithness, length: MemoryLayout<Float>.stride, index: 0)

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
