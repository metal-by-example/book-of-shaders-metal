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
    // We can plot arbitrary functions just like we did with our line.
    // First, we find the vertical distance from the function to the
    // current pixel's y coordinate; this is 0 along the function.
    float d = f - st.y;
    // The difference of two smoothstep calls is a smoothed square pulse,
    // which widens a curve of infinite thinness into a plot we can see.
    return smoothstep(-halfWidth, 0.0f, d) -
           smoothstep(0.0f, halfWidth, d);
}

[[fragment]]
float4 fragment_main(FragmentIn in [[stage_in]],
                     constant Uniforms &uniforms [[buffer(0)]])
{
    float2 st = in.st;
    st = st * 2.0f - 1.0f; // Transform x and y to span from -1 to 1

    // We perform exponentiation by using the powr() function.
    // A fifth-order polynomial like x^5 is called a quintic.
    float y = powr(st.x, 5.0f);

    // First we plot the background gradient which shows the
    // magnitude of x^5 for each x as a grayscale gradient.
    float3 color = float3(abs(y));

    // Then we blend the function plot on top
    float coverage = plot(st, y, 0.025f);
    color = (1.0f - coverage) * color + coverage * float3(0.0f, 1.0f, 0.0f);

    return float4(color, 1.0f);
}
