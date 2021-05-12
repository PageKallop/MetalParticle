//
//  MainView.swift
//  MetalParticle
//
//  Created by Page Kallop on 5/12/21.
//

import UIKit
import MetalKit

class MainView: MTKView {
    
    var commandQueue: MTLCommandQueue!
    
    var clearPass: MTLComputePipelineState!
    
    @IBOutlet weak var metalView: MTKView!
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        //allows to draw to frame buffer
        self.framebufferOnly = false
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        
        let clearFunc = library?.makeFunction(name: "clear_pass_func")
        
        do {
            clearPass = try device?.makeComputePipelineState(function: clearFunc as! MTLFunction)
        } catch{
            print("Error")
        }
    }

}

extension MainView {
    
    override func draw(_ rect: CGRect) {
        //drawable that texture is updated 
        guard let drawable = self.currentDrawable else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        //encode compute func variables
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        //clears
        computeCommandEncoder?.setComputePipelineState(clearPass)
        //sets the texture
        computeCommandEncoder?.setTexture(drawable.texture, index: 0)
        
       //determine how many threads in grid
        let w = clearPass.threadExecutionWidth
        let h = clearPass.maxTotalThreadsPerThreadgroup / w
        
        var threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        
        var threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        computeCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
