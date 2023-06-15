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

float line(float2 st, float halfWidth) {
    // The expression st.y - st.x is exactly 0 on the line y = x.
    // Since a line is infinitely thin, we use smoothstep to blend
    // from  1 along the centerline to 0 a short distance away,
    // thus thickening the line.
    float v = st.y - st.x;
    return smoothstep(-halfWidth, 0.0f, v) -
           smoothstep(0.0f, halfWidth, v);
}

[[fragment]]
float4 fragment_main(FragmentIn in [[stage_in]],
                     constant Uniforms &uniforms [[buffer(0)]])
{
    float2 st = in.st;
    float y = st.x;

    // Start by shading the background with a horizontal gray gradient
    float3 color = float3(y);

    // Calculate the coverage of the line
    float lineCoverage = line(st, 0.01f);

    // Manually blend (interpolate) from the background gradient to
    // the line based on how close we are to the line.
    color = (1.0f - lineCoverage) * color +
            lineCoverage * float3(0.0f, 1.0f, 0.0f);

    return float4(color, 1.0f);
}
