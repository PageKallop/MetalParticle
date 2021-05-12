//
//  Shader.metal
//  MetalParticle
//
//  Created by Page Kallop on 5/12/21.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float4 color;
    float2 position;
    float2 velocity;
};

//passing function to update pic
kernel void clear_pass_func(texture2d<half, access:: write> tex [[ texture(0) ]],
                            //creates unique thread
                            uint2 id [[ thread_position_in_grid]]){
    //creates color
    tex.write(half4(0), id);
    
}

kernel void draw_dots_func(device Particle *particles [[ buffer(0) ]],
                           texture2d<half, access::write> tex [[ texture(0) ]],
                           uint id [[ thread_position_in_grid]]){
    
    Particle particle;
    particle = particles[id];
    
    float2 position = particle.position;
    float2 velocity = particle.velocity;
    half4 color = half4(particle.color.r, particle.color.g, particle.color.b, 1);
    
    
    uint2 texturePosition = uint2(position.x, position.y);
    tex.write(color, texturePosition);
    tex.write(color, texturePosition + uint2(1,0));
    tex.write(color, texturePosition + uint2(1,0));
    
}
