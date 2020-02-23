//
//  TextureLoader.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 17/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import MetalKit

class TextureLoader {

    enum Error: Swift.Error {
        case imageNotFound
        case invalidTexture
    }
    let textureLoader: MTKTextureLoader

    init(device: MTLDevice) {
        self.textureLoader = MTKTextureLoader(device: device)
    }

    func get(named: String, extension: String) throws -> (in: MTLTexture, out: MTLTexture) {
        guard let url = Bundle.main.url(forResource: named, withExtension: `extension`) else {
            throw Error.imageNotFound
        }

        let textureLoaderOption: [MTKTextureLoader.Option: Any] = [
            .allocateMipmaps: NSNumber(value: false),
            .SRGB: NSNumber(value: false)
        ]
        guard let inTexture = try? textureLoader.newTexture(URL: url, options: textureLoaderOption) else {
            throw Error.imageNotFound
        }

        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: inTexture.width,
            height: inTexture.height,
            mipmapped: false)

        outTextureDescriptor.usage = [.shaderWrite, .shaderRead]
        guard let outTexture = textureLoader.device.makeTexture(descriptor: outTextureDescriptor) else {
            throw Error.invalidTexture
        }

        return (inTexture, outTexture)
    }
}
