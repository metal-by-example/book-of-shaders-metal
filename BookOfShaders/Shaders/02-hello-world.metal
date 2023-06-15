#include <metal_stdlib>
using namespace metal;

[[fragment]]
float4 fragment_main() {
    // Return a solid color for every pixel (magenta by default).
    // The fourth component of the color is alpha, representing
    // opacity. It has no effect because blending isn't enabled.
    // But try changing the other values to change the color!
    return float4(1.0f, 0.0f, 1.0f, 1.0f);
}
