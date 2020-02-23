//
//  ViewController.swift
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 16/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

import UIKit
import MetalKit
import Metal

class ViewController: UIViewController {

    private let metalView = MTKView(frame: .zero)
    var textureLoader: TextureLoader!
    var textureRenderer: TextureRenderer!

    var textures: (MTLTexture, MTLTexture)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.framebufferOnly = false
        metalView.autoResizeDrawable = false
        view.addSubview(metalView)
        metalView.delegate = self
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            metalView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    private func setup() {
        do {
            textureRenderer = try TextureRenderer(functionName: "brithnessAdjustment")
            textureLoader = TextureLoader(device: textureRenderer.device)
            metalView.device = textureRenderer.device
            textures = try textureLoader.get(named: "peru", extension: "jpeg")
        } catch {
            print(error)
        }
    }

}

extension ViewController: MTKViewDelegate {

    func draw(in view: MTKView) {
        guard let textures = textures, let drawable = metalView.currentDrawable else { return }
        textureRenderer.applyKernel(inTexture: textures.0, outTexture: textures.1, into: drawable)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
