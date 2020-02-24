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
                                constant BrightnessUniform& uniform [[ buffer(0) ]],
                                uint2 gid [[ thread_position_in_grid ]]) {
    if ((gid.x >= inTexture.get_width()) || (gid.y >= inTexture.get_height())) {
        return;
    }
    half3 color = inTexture.read(gid).rgb;
    outTexture.write(half4(color + uniform.brightness, 1), gid);
}
