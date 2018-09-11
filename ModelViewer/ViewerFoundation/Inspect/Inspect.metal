//
//  Inspect.metal
//  ModelViewer
//
//  Created by middleware on 9/11/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#include <metal_stdlib>
#include "Meshes/ShadersCommon.h"


using namespace metal;


fragment float4 fragment_checker(PositionTextureSimple vert [[stage_in]])
{
    int row = (int)(vert.position.x / 20) % 2;
    int col = (int)(vert.position.y / 20) % 2;
    
    float4 color = (row == col)? float4(1.0, 1.0, 1.0, 1.0) : float4(0.85, 0.85, 0.85, 1.0);
    return color;
}