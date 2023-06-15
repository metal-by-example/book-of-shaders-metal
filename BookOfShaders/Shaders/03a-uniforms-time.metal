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
    // The time value is populated by the CPU every frame, so
    // it can be used to animate. In this case, we take the
    // sine of the time value to get a value that oscillates
    // between -1 and 1, then take its absolute value to get
    // a value that "bounces" at 0 and peaks at 1.
    return float4(abs(sin(uniforms.time)), 0.0f, 0.0f, 1.0f);
}
