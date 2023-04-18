//
//  Vertex.hpp
//  Graphics
//
//  Created by Landon Teeter on 3/21/23.
//

#ifndef Vertex_hpp
#define Vertex_hpp

#include <metal_stdlib>
using namespace metal;

struct Vertex{
    float4 position [[attribute(0)]];
};

struct VertexOut{
    float4 position [[position]];
};

#endif /* Vertex_hpp */
