//
//  Shader.metal
//  MetalParticle
//
//  Created by Page Kallop on 5/12/21.
//

#include <metal_stdlib>
using namespace metal;


//passing function to update pic
kernel void clear_pass_func(texture2d<half, access:: write> tex [[ texture(0) ]],
                            //creates unique thread
                            uint2 id [[ thread_position_in_grid]]){
    //creates color
    tex.write(half4(1,0,0,1), id);
    
}


