#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float2 resolution;
    float2 mouse;
    float time;
};

[[fragment]]
float4 fragment_main(constant Uniforms &uniforms [[buffer(0)]])
{
    return float4(abs(sin(uniforms.time)), 0.0f, 0.0f, 1.0f);
}
