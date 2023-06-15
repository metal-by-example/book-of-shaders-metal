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

float plot(float2 st, float f, float halfWidth) {
    float d = f - st.y;
    return smoothstep(-halfWidth, 0.0f, d) -
           smoothstep(0.0f, halfWidth, d);
}

[[fragment]]
float4 fragment_main(FragmentIn in [[stage_in]],
                     constant Uniforms &uniforms [[buffer(0)]])
{
    float2 st = in.st;

    // The step() function returns 0 if its second argument is
    // less than its first argument, and 1 otherwise.
    float y = step(0.5f, st.x);

    float3 color = float3(y);

    float coverage = plot(st, y, 0.02f);
    color = (1.0f - coverage) * color + coverage * float3(0.0f, 1.0f, 0.0f);

    return float4(color, 1.0f);
}
