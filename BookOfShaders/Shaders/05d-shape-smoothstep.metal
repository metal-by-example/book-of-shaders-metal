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

float plot(float2 st, float f, float width) {
    float d = f - st.y;
    return smoothstep(-width * 0.5f, 0.0f, d) -
           smoothstep(0.0f, width * 0.5f, d);
}

[[fragment]]
float4 fragment_main(FragmentIn in [[stage_in]],
                     constant Uniforms &uniforms [[buffer(0)]])
{
    float2 st = in.st;

    // We've been using smoothstep to plot other functions,
    // now we use it to plot the smoothstep() function itself.
    // Smoothstep smoothly interpolates from 0 to 1 when its
    // third argument is between its first two arguments.
    float y = smoothstep(0.1f, 0.9f, st.x);

    float3 color = float3(y);

    float coverage = plot(st, y, 0.03f);
    color = (1.0f - coverage) * color +
            coverage * float3(0.0f, 1.0f, 0.0f);

    return float4(color, 1.0f);
}
