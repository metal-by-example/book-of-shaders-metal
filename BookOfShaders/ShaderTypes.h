
#pragma once
#include <simd/simd.h>

typedef struct Uniforms {
    simd_float2 resolution;
    simd_float2 mouse;
    float time;
} Uniforms;
