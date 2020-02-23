//
//  Metal.metal
//  ImageEditor
//
//  Created by Grzegorz Przybyła on 16/02/2020.
//  Copyright © 2020 Grzegorz Przybyła. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float brightness;
} BrightnessUniform;


kernel void brithnessAdjustment(texture2d<half, access::read> inTexture [[ texture(0)]],
                                texture2d<half, access::read_write> outTexture [[ texture(1) ]],
                                uint2 gid [[ thread_position_in_grid ]]) {
    half3 color = inTexture.read(gid).rgb;
    outTexture.write(half4(color, 1), gid);
}
