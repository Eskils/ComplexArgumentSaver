//
//  Functions.metal
//  ComplexArgument
//
//  Created by Eskil Sviggum on 04/10/2022.
//

#include <metal_stdlib>
using namespace metal;

float cmpx_modulus(float2 z) {
    return sqrt(pow(z.x, 2) + pow(z.y, 2));
}

float cmpx_argument(float2 z) {
    return atan2(z.y, z.x);
}

float2 cmpx_fromModArg(float mod, float arg) {
    return float2(mod * cos(arg),
                  mod * sin(arg));
}

float2 cmpx_pow(float2 z, float power) {
    float mod = cmpx_modulus(z);
    float arg = cmpx_argument(z);
    
    return cmpx_fromModArg(pow(mod, power),
                           power * arg);
}

float2 cmpx_mul(float2 z1, float2 z2) {
    return float2(z1.x * z2.x - z1.y * z2.y,
                  z1.x * z2.y + z1.y * z2.x);
}

float2 cmpx_add(float2 z1, float2 z2) {
    return float2(z1.x + z2.x,
                  z1.y + z2.y);
}

float4 rgbFromHue(float hue) {
    float r = max(0.0f, cos(M_PI_F * 3/2 * hue));
    float g = max(0.0f, sin(M_PI_F * 3/2 * hue));
    float b = max(0.0f, sin(M_PI_F * 3/2 * hue + M_PI_F * 3/2));
    
    return float4(r, g, b, 1);
}


kernel void modular(texture2d<float, access::write> outTexture [[texture(0)]],
                    device const float2 *a [[buffer(0)]],
                    device const float2 *b [[buffer(1)]],
                    device const float *power [[buffer(2)]],
                    uint2 gid [[thread_position_in_grid]])

{
    float size = (float)outTexture.get_width();
    float x = 2 * (float)gid.x / size - 1;
    float y = 2 * (float)gid.y / size - 1;
    
    float2 point = float2(x,y);
    float2 t1 = cmpx_pow(point, *power);
    float2 t2 = cmpx_mul(*a, point);
    float2 ySquared = cmpx_add(cmpx_add(t1, t2), *b);
    float2 z = cmpx_pow(ySquared, 0.5f);
    
    float4 pixel = rgbFromHue(cmpx_argument(z));

    outTexture.write(pixel, gid);
}
