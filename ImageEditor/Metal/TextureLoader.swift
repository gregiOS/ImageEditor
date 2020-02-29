//
//  TextureLoader.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 17/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import UIKit
import MetalKit

class TextureLoader {
    let textureLoader: MTKTextureLoader
    private let options: [MTKTextureLoader.Option: Any] = [
        .allocateMipmaps: NSNumber(value: false),
        .SRGB: NSNumber(value: false)
    ]

    init(device: MTLDevice) {
        self.textureLoader = MTKTextureLoader(device: device)
    }

    func newTexture(with image: UIImage) throws -> MTLTexture {
        guard let cgImage = image.cgImage else {
            throw Error.cgImageNotExists
        }

        let texture = try textureLoader.newTexture(cgImage: cgImage, options: options)
        return texture
    }

    func get(named: String, extension: String) throws -> MTLTexture {
        guard let url = Bundle.main.url(forResource: named, withExtension: `extension`) else {
            throw Error.imageNotFound
        }

        let inTexture = try textureLoader.newTexture(URL: url, options: options)
        return inTexture
    }
}

extension TextureLoader {
    enum Error: Swift.Error {
        case cgImageNotExists
        case imageNotFound
        case invalidTexture
    }
}
