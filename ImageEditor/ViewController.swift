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
    private lazy var metalView: MTKView = ViewBuilder.make(inside: view)
    private lazy var slider: UISlider = ViewBuilder.make(inside: view)
    private lazy var brithnessImageView: UIImageView = ViewBuilder.make(inside: view) {
        $0.image = #imageLiteral(resourceName: "brithness")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }

    var textureLoader: TextureLoader!
    var textureRenderer: TextureRenderer!

    var inTexture: MTLTexture?
    var currentKernels: [Kernel] = [BrithnessKernel(brithness: 0)]

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeConstraints()
        setupBrithnessSlider()
        setupMetalView()
        setupMetal()
    }

    private func initializeConstraints() {
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metalView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            brithnessImageView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            brithnessImageView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            brithnessImageView.heightAnchor.constraint(equalToConstant: 25),
            brithnessImageView.widthAnchor.constraint(equalToConstant: 25),
            slider.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            slider.leadingAnchor.constraint(equalTo: brithnessImageView.trailingAnchor, constant: 12),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBrithnessSlider() {
        slider.addTarget(self, action: #selector(didChangeState), for: .valueChanged)
        slider.value = 0.5
    }

    private func setupMetalView() {
        metalView.framebufferOnly = false
        metalView.autoResizeDrawable = false
        metalView.delegate = self
    }

    private func setupMetal() {
        do {
            let device = MTLCreateSystemDefaultDevice()!
            textureRenderer = try TextureRenderer(device: device)
            textureLoader = TextureLoader(device: device)
            metalView.device = device
            inTexture = try textureLoader.get(named: "peru", extension: "jpeg")
        } catch {
            assertionFailure("Error occured whiel setup metal: \(error)")
        }
    }

    @objc func didChangeState(sender: UISlider) {
        guard let index = currentKernels.firstIndex(where: { $0 is BrithnessKernel }) else { return }
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
