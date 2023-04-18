//
//  Shaders.metal
//  Graphics
//
//  Created by Landon Teeter on 3/21/23.
//

#include <metal_stdlib>
using namespace metal;

#include "Vertex.hpp"
#include "Uniforms.h"

kernel void kernelShader(device Vertex *out [[buffer(0)]], uint id [[thread_position_in_grid]]){
    Vertex v;
    
    uint i = id % 3;
    if(i == 0){
        v.position = float4(0.0,  1.0,  0.0, 1.0);
        out[id] = v;
        return;
    }

    if(i == 1){
        v.position = float4(-1.0, -1.0, 0.0, 1.0);
        out[id] = v;
        return;
    }
    
    if(i == 2){
        v.position = float4(1.0,  -1.0, 0.0, 1.0);
        out[id] = v;
        return;
    }
    
    return;
}

 
vertex VertexOut vertexShader(const Vertex in [[stage_in]], const constant VertexUniforms &uniforms [[buffer(1)]]){
    VertexOut out;
    out.position = in.position;
    return out;
}

fragment half4 fragmentShader(VertexOut v [[stage_in]], const constant FragmentUniforms &uniforms [[buffer(0)]]){
    return half4(half(uniforms.red), half(uniforms.green), half(uniforms.blue), 0.5);
}
