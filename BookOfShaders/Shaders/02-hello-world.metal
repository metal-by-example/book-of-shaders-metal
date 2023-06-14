#include <metal_stdlib>
using namespace metal;

[[fragment]]
float4 fragment_main() {
    return float4(1.0f, 0.0f, 1.0f, 1.0f);
}
