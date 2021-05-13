//
//  MainView.swift
//  MetalParticle
//
//  Created by Page Kallop on 5/12/21.
//

import UIKit
import MetalKit

struct Particle {
    var color : float4
    var position : float2
    var velocity : float2
}

class MainView: MTKView {
    
    var commandQueue: MTLCommandQueue!
    
    //pipeline states
    var clearPass: MTLComputePipelineState!
    
    var drawDotPass: MTLComputePipelineState!
    
    var particleBuffer: MTLBuffer!
    
    var screenSize: Float {
        return Float(self.bounds.width)
    }
    
    var particleCount: Int = 100 
    
    @IBOutlet weak var metalView: MTKView!
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        //allows to draw to frame buffer
        self.framebufferOnly = false
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        
        let clearFunc = library?.makeFunction(name: "clear_pass_func")
        
        let drawDotFunc = library?.makeFunction(name: "draw_dots_func")
        
        do {
            clearPass = try device?.makeComputePipelineState(function: clearFunc!)
     
        } catch{
            print("Error")
        }
        do {
           
            drawDotPass = try device?.makeComputePipelineState(function: drawDotFunc!)
        } catch{
            print("Error")
        }
        
        createParticles()
        
    }
    
    func createParticles(){
        var particles: [Particle] = []
        for _ in 0..<particleCount {
            let red: Float = Float(arc4random_uniform(100)) / 100
            let green: Float = Float(arc4random_uniform(100)) / 100
            let blue: Float = Float(arc4random_uniform(100)) / 100
            let particle = Particle(color: float4(red, green, blue, 1),
                                    position: float2(Float(arc4random_uniform(UInt32(screenSize))),
                                                     Float(arc4random_uniform(UInt32(screenSize)))),
                                    velocity: float2((Float(arc4random() % 10) - 5) / 10,
                                                     (Float(arc4random() % 10) - 5) / 10))
            
            particles.append(particle)
        }
        
        particleBuffer = device?.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * particleCount, options: [])
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
        
        
        var threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        
        var threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        //change pipeline state
        computeCommandEncoder?.setComputePipelineState(drawDotPass)
        computeCommandEncoder?.setBuffer(particleBuffer, offset: 0, index: 0)
        //update threads per grid
        threadsPerGrid = MTLSize(width: w, height: 1, depth: 1)
        threadsPerThreadGroup = MTLSize(width: particleCount, height: 1, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        computeCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
