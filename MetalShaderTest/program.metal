//
//  program.metal
//  MetalCustomShaderTest
//
//  Created by sneha belkhale on 9/3/18.
//  Copyright © 2018 Codercat. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <SceneKit/scn_metal>

struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
};

typedef struct {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texCoords [[ attribute(SCNVertexSemanticTexcoord0) ]];
} MyVertexInput;

struct SimpleVertex
{
    float4 position [[position]];
    float2 texCoords;
};

//custom uniforms
struct BezierPoints {
    float3 p0;
    float3 p1;
    float3 p2;
    float3 p3;
};

float3 CubicBezierP0 (float t, float3 p) {
    float k = 1 - t;
    return k * k * k * p;
}
float3 CubicBezierP1 (float t, float3 p) {
    float k = 1 - t;
    return 3 * k * k * t * p;
}
float3 CubicBezierP2 (float t, float3 p) {
    return 3 * ( 1 - t ) * t * t * p;
}
float3 CubicBezierP3 (float t, float3 p) {
    return t * t * t * p;
}

//custom uniform is bound to buffer 2, can be accessed in both vertex and fragment shader
vertex SimpleVertex flexVertex(MyVertexInput in [[ stage_in ]],
                             constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                             constant MyNodeBuffer& scn_node [[buffer(1)]],
                             constant BezierPoints& bezierPoints [[buffer(2)]])
{

    float t = in.position.y + 0.5;

    float3 np = CubicBezierP0( t, bezierPoints.p0 ) + CubicBezierP1( t, bezierPoints.p1 ) + CubicBezierP2( t, bezierPoints.p2 ) + CubicBezierP3( t, bezierPoints.p3 );
    np.x += in.position.x;

    SimpleVertex vert;
    vert.position = scn_node.modelViewProjectionTransform * float4(np, 1.0);
    vert.texCoords = in.texCoords;

    return vert;
}

fragment float4 flexFragment(SimpleVertex in [[stage_in]],
                          constant BezierPoints& bezierPoints [[buffer(2)]]
                          )
{
    return float4(0.2*bezierPoints.p2, 1.0);
}
