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
    private lazy var brithnessSlider: UISlider = ViewBuilder.make(inside: view)
    private lazy var brithnessImageView: UIImageView = ViewBuilder.make(inside: view) {
        $0.image = #imageLiteral(resourceName: "brithness")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }

    var textureLoader: TextureLoader!
    var textureRenderer: TextureRenderer!

    var inTexture: MTLTexture?
    var currentKernels: [Kernel] = [BrightnessKernel(brightness: 0)]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
            brithnessSlider.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            brithnessSlider.leadingAnchor.constraint(equalTo: brithnessImageView.trailingAnchor, constant: 12),
            brithnessSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBrithnessSlider() {
        brithnessSlider.addTarget(self, action: #selector(didChangeState), for: .valueChanged)
        brithnessSlider.value = 0.5
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
            inTexture = try textureLoader.newTexture(with: #imageLiteral(resourceName: "peru.jpeg"))
        } catch {
            assertionFailure("Error occured: \(error)")
        }
    }

    @objc func didChangeState(sender: UISlider) {
        guard let index = currentKernels.firstIndex(where: { $0 is BrightnessKernel }) else { return }
        var brightnessKernel = currentKernels[index] as! BrightnessKernel
        brightnessKernel.brightness = sender.value - 0.5
        currentKernels[index] = brightnessKernel
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let inTexture = inTexture, let drawable = metalView.currentDrawable else { return }
        autoreleasepool { [weak self] in
            self?.currentKernels.forEach { kernel in
                self?.textureRenderer.apply(kernel: kernel, inTexture: inTexture, into: drawable)
            }
        }

    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
