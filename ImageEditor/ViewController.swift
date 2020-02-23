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
    private let slider = UISlider()
    var textureLoader: TextureLoader!
    var textureRenderer: TextureRenderer!

    var textures: (MTLTexture, MTLTexture)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        slider.translatesAutoresizingMaskIntoConstraints = false
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.framebufferOnly = false
        metalView.autoResizeDrawable = false
        view.addSubview(metalView)
        view.addSubview(slider)
        metalView.delegate = self
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metalView.topAnchor.constraint(equalTo: view.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            slider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        slider.addTarget(self, action: #selector(didChangeState), for: .valueChanged)
        slider.value = 0.5
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

    @objc func didChangeState(sender: UISlider) {
        textureRenderer.brithness = sender.value - 0.5
    }

}

extension ViewController: MTKViewDelegate {

    func draw(in view: MTKView) {
        guard let textures = textures, let drawable = metalView.currentDrawable else { return }
        textureRenderer.applyKernel(inTexture: textures.0, outTexture: textures.1, into: drawable)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
