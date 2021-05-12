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
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
    }
}
