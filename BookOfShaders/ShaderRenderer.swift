import MetalKit

class ShaderRenderer : NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState?
    private let defaultLibrary: MTLLibrary

    var sceneTime: TimeInterval = 0.0
    var lastRenderTime: TimeInterval

    var example: ShaderExample? {
        didSet {
            renderPipelineState = nil
        }
    }

    var fragmentFunctionSource: String? {
        didSet {
            renderPipelineState = nil
        }
    }

    private var lastFragmentFunctionSource: String? = nil

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        lastRenderTime = CACurrentMediaTime()
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            fatalError("Unable to create default Metal library")
        }
        self.defaultLibrary = defaultLibrary

        super.init()
    }

    func makePipeline(view: MTKView) {
        guard let fragmentShaderSource = fragmentFunctionSource else { return }
        guard let fragmentEntryPoint = example?.entryPoint else { return }

        // Whatever the outcome of the previous compilation, don't recompile if nothing's changed.
        if (lastFragmentFunctionSource == fragmentShaderSource) {
            return
        }

        var fragmentLibrary: MTLLibrary? = nil
        do {
            fragmentLibrary = try device.makeLibrary(source: fragmentShaderSource, options: nil)
        } catch {
            let nsError = error as NSError
            print("\(nsError.localizedDescription)")
            lastFragmentFunctionSource = fragmentShaderSource
            return
        }

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat

        guard let vertexFunction = defaultLibrary.makeFunction(name: "vertex_main") else { return }
        guard let fragmentFunction = fragmentLibrary?.makeFunction(name: fragmentEntryPoint) else { return }
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction

        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print("Error while creating render pipeline state: \(error)")
        }
    }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        if renderPipelineState == nil {
            makePipeline(view: view)
        }

        guard let renderPipelineState else {
            return
        }

        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        var mouseX: Float = 0.0, mouseY: Float = 0.0
        if let currentMouseLocation = view.window?.mouseLocationOutsideOfEventStream {
            var mouseLocationInView = view.convert(currentMouseLocation, from: nil)
            mouseLocationInView = view.convertToBacking(mouseLocationInView)
            mouseX = Float(mouseLocationInView.x)
            mouseY = Float(mouseLocationInView.y)
        }

        let currentTime = CACurrentMediaTime()
        let timestep = currentTime - lastRenderTime

        var uniforms = Uniforms(resolution: SIMD2<Float>(Float(view.drawableSize.width),
                                                         Float(view.drawableSize.height)),
                                mouse: SIMD2<Float>(mouseX, mouseY),
                                time: Float(sceneTime))

        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderCommandEncoder.endEncoding()

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()

        sceneTime += timestep
        lastRenderTime = currentTime
    }
}
