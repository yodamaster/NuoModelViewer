//
//  NuoBoardMesh.m
//  ModelViewer
//
//  Created by middleware on 6/6/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#import "NuoBoardMesh.h"



@implementation NuoBoardMesh
{
    NuoMeshModeShaderParameter _meshMode;
    NuoCoord* _dimensions;
}



- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue
                  withVerticesBuffer:(void *)buffer withLength:(size_t)length
                         withIndices:(void *)indices withLength:(size_t)indicesLength
                       withDimension:(NuoCoord*)dimensions
{
    self = [super initWithCommandQueue:commandQueue
                    withVerticesBuffer:buffer withLength:length
                           withIndices:indices withLength:indicesLength];
    
    if (self)
    {
        _dimensions = dimensions;
        _meshMode = kMeshMode_Normal;
    }
    
    return self;
}



- (instancetype)cloneForMode:(NuoMeshModeShaderParameter)mode
{
    NuoBoardMesh* boardMesh = [NuoBoardMesh new];
    [boardMesh shareResourcesFrom:self];
    
    boardMesh->_meshMode = mode;
    
    [boardMesh makePipelineShadowState];
    [boardMesh makePipelineState:[boardMesh makePipelineStateDescriptor]];
    [boardMesh makeDepthStencilState];
    
    return boardMesh;
}



- (MTLRenderPipelineDescriptor*)makePipelineStateDescriptor
{
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    NSString* vertexFunc = @"vertex_project_shadow";
    NSString* fragmnFunc = @"fragment_light_shadow";
    
    MTLFunctionConstantValues* funcConstant = [MTLFunctionConstantValues new];
    [funcConstant setConstantValue:&_shadowOverlayOnly type:MTLDataTypeBool atIndex:3];
    [funcConstant setConstantValue:&kShadowPCSS type:MTLDataTypeBool atIndex:4];
    [funcConstant setConstantValue:&kShadowPCF type:MTLDataTypeBool atIndex:5];
    [funcConstant setConstantValue:&_meshMode type:MTLDataTypeInt atIndex:6];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:vertexFunc];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:fragmnFunc
                                                        constantValues:funcConstant error:nil];
    pipelineDescriptor.sampleCount = kSampleCount;
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    MTLRenderPipelineColorAttachmentDescriptor* colorAttachment = pipelineDescriptor.colorAttachments[0];
    colorAttachment.blendingEnabled = YES;
    colorAttachment.rgbBlendOperation = MTLBlendOperationAdd;
    colorAttachment.alphaBlendOperation = MTLBlendOperationAdd;
    colorAttachment.sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    colorAttachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    colorAttachment.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    return pipelineDescriptor;
}

- (void)makePipelineShadowState
{
    [super makePipelineShadowState:@"vertex_shadow"];
}


- (void)makePipelineScreenSpaceState
{
    MTLFunctionConstantValues* constants = [MTLFunctionConstantValues new];
    BOOL shadowOverlay = YES;
    [constants setConstantValue:&shadowOverlay type:MTLDataTypeBool atIndex:3];
    
    [super makePipelineScreenSpaceStateWithVertexShader:@"vertex_project_screen_space"
                                     withFragemtnShader:@"fragement_screen_space"
                                          withConstants:constants];
}


- (void)drawMesh:(id<MTLRenderCommandEncoder>)renderPass indexBuffer:(NSInteger)index
{
    [renderPass setCullMode:MTLCullModeBack];
    [super drawMesh:renderPass indexBuffer:index];
}


- (NuoCoord*)dimensions
{
    return _dimensions;
}


@end
