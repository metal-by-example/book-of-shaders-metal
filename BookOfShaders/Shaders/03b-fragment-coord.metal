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

[[fragment]]
float4 fragment_main(FragmentIn in [[stage_in]],
                     constant Uniforms &uniforms [[buffer(0)]])
{
    // We divide the fragment's position, which is in viewport
    // coordinates, by the viewport dimensions to get a set of
    // coordinates in the range (0, 1). We then invert the y
    // coordinate because in Metal, the origin of texture space
    // is in the upper left, while in OpenGL, the origin is
    // in the bottom left. The resulting value is the same as
    // the one we get from the vertex shader (in.st), but this
    // is another way of calculating it when you don't have
    // access to interpolated coordinates.
    float2 st = in.position.xy / uniforms.resolution;
    st.y = 1.0f - st.y;

    return float4(st, 0.0f, 1.0f);
}
