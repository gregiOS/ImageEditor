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
    private let metalView = MTKView()
    private let slider = UISlider()
    var textureLoader: TextureLoader!
    var textureRenderer: TextureRenderer!

    var inTexture: MTLTexture?
    var currentKernels: [Kernel] = []

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
            let device = MTLCreateSystemDefaultDevice()!
            textureRenderer = try TextureRenderer(device: device)
            textureLoader = TextureLoader(device: device)
            metalView.device = device
            inTexture = try textureLoader.get(named: "peru", extension: "jpeg")
        } catch {
            print(error)
        }
    }

    @objc func didChangeState(sender: UISlider) {
        guard let index = currentKernels.firstIndex(where: { $0 is BrithnessKernel }) else {
            let kernel = BrithnessKernel(brithness: sender.value - 0.5)
            currentKernels.append(kernel)
            return
        }
        currentKernels[index] = BrithnessKernel(brithness: sender.value - 0.5)
    }

}

extension ViewController: MTKViewDelegate {

    func draw(in view: MTKView) {
        guard let inTexture = inTexture, let drawable = metalView.currentDrawable else { return }
        currentKernels.forEach { kernel in
            textureRenderer.apply(kernel: kernel, inTexture: inTexture, into: drawable)
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
