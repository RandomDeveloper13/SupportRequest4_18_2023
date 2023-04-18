//
//  GraphicsViewController.swift
//  Graphics
//
//  Created by Landon Teeter on 3/21/23.
//

import UIKit
import Metal

class GraphicsViewController : UIViewController{
    static let vertexCount : Int = 300_000
    static let vertexSize  : Int = MemoryLayout<Vertex>.stride
    
    var layer : CAMetalLayer!

    var device        : MTLDevice!
    var library       : MTLLibrary!
    var commandQueue  : MTLCommandQueue!
    var vertexBuffer  : MTLBuffer?
    
    var renderPipelineState : MTLRenderPipelineState!    

    
    private func vertexUniforms() -> VertexUniforms{
        return VertexUniforms(cgWidth: Float(self.view.bounds.width), cgHeight: Float(self.view.bounds.height))
    }
    
    private func fragmentUniforms() -> FragmentUniforms{
        return FragmentUniforms(red: Float.random(in: 0...1), green: Float.random(in: 0...1), blue: Float.random(in: 0...1))
    }
    
    @objc private func render(){
        autoreleasepool{
            var vertexUniformBuffer : MTLBuffer?
            vertexUniformBuffer =& (self.device, vertexUniforms())

            
            var fragmentUniformBuffer : MTLBuffer?
            fragmentUniformBuffer =& (self.device, fragmentUniforms())
            
            let renderCommandBuffer  = self.commandQueue.makeCommandBuffer()!
            
            guard let drawable = self.layer.nextDrawable() else { return }
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            
            let renderCommandEncoder = renderCommandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
            
            renderCommandEncoder.setVertexBuffer(self.vertexBuffer,       offset: 0, index: 0)
            renderCommandEncoder.setVertexBuffer(vertexUniformBuffer,     offset: 0, index: 1)
            renderCommandEncoder.setFragmentBuffer(fragmentUniformBuffer, offset: 0, index: 0)
            
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Self.vertexCount)
            renderCommandEncoder.endEncoding()
            
            #warning("Add completed handler")
            
            renderCommandBuffer.present(drawable)
            renderCommandBuffer.commit()
        }
    }
    
    func fillVertexBuffer(){
        let kernelFunction       = self.library.makeFunction(name: "kernelShader")!
        let computePipelineState = try! self.device.makeComputePipelineState(function: kernelFunction)

        let maxTotalThreadsPerThreadgroup = computePipelineState.maxTotalThreadsPerThreadgroup
        let threadsPerThreadgroup = MTLSize(width: maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
        let numberOfThreadgroups = MTLSize(width: (Self.vertexCount + maxTotalThreadsPerThreadgroup - 1)/maxTotalThreadsPerThreadgroup, height: 1, depth: 1)
        
        
        let computeCommandBuffer  = self.commandQueue.makeCommandBuffer()!
        let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()!
        
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setBuffer(self.vertexBuffer, offset: 0, index: 0)
        computeCommandEncoder.dispatchThreadgroups(numberOfThreadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder.endEncoding()
        
        #warning("Add completed handler")
        
        computeCommandBuffer.commit()
        computeCommandBuffer.waitUntilCompleted()
    }
    
    override func viewDidLoad(){
        self.device        = MTLCreateSystemDefaultDevice()!
        self.library       = self.device.makeDefaultLibrary()!
        self.commandQueue  = self.device.makeCommandQueue()!
        self.vertexBuffer  = self.device.makeBuffer(length: Self.vertexCount*Self.vertexSize, options: MTLResourceOptions.storageModePrivate)!
        
        self.layer = CAMetalLayer()
        self.layer.pixelFormat = .bgra8Unorm
        self.layer.framebufferOnly = true
        self.layer.contentsScale = UIScreen.main.scale;
        self.layer.frame = view.bounds
        self.layer.device = self.device


        self.fillVertexBuffer()


        let vertexFunction   = self.library.makeFunction(name: "vertexShader")!
        let fragmentFunction = self.library.makeFunction(name: "fragmentShader")!
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        let renderPipelineDescriptor                             = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor                = vertexDescriptor
        renderPipelineDescriptor.vertexFunction                  = vertexFunction
        renderPipelineDescriptor.fragmentFunction                = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        
        
        
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.addSublayer(self.layer)

        

        let button = UIButton()
        button.setTitle("Generate new color", for: .normal)
        button.addTarget(self, action: #selector(render), for: .touchDown)
        button.sizeToFit()
        view.addSubview(button)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layer.frame = view.bounds
        self.render()
    }
}
