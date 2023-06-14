
#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 st;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]])
{
    float2 positions[] = { float2(-1.0f, 1.0f), float2(-1.0f, -3.0f), float2(3.0f, 1.0f) };
    float2 texCoords[] = { float2(0.0f, 0.0f), float2(0.0f, 2.0f), float2(2.0f, 0.0f) };

    float4 clipPosition = float4(positions[vertexID], 0.0f, 1.0f);
    float2 texCoord = texCoords[vertexID];
    texCoord.y = 1.0f - texCoord.y; // Flip to GL convention

    VertexOut out {
        .position = clipPosition,
        .st = texCoord,
    };

    return out;
}
