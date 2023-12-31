#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float2 resolution;
    float2 mouse;
    float time;
};

struct FragmentIn {
    float4 position [[position]];
    float2 st;
};

constant float3 colorA { 0.000f, 0.129f, 0.647f };
constant float3 colorB { 0.980f, 0.275f, 0.090f };

[[fragment]]
float4 fragment_main(FragmentIn in [[stage_in]],
                     constant Uniforms &uniforms [[buffer(0)]])
{
    // Vary the proportion of colors as a function of time.
    // Sine oscillates between -1 and 1 so we scale and offset
    // to get a value ranging from 0 to 1.
    float fraction =sin(uniforms.time) * 0.5 + 0.5f;

    // The mix() function linearly interpolates between its
    // first two arguments based on its third argument (0-1).
    float3 color = mix(colorA, colorB, fraction);

    return float4(color,1.0);
}
