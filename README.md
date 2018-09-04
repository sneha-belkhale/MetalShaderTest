# MetalShaderTest

I thought I would share a very simple example of how to pass in custom uniforms to a metal shader in Swift / SceneKit, since for some reason there is absolutely no coded example of how to do this. 

## Main Steps

[1] define a struct for you uniforms
```
struct Uniforms {
    float3 uColor;
};
```
[2] instantiate them 
```
let color = float3(1,1,0);
var uniforms = Uniforms(uColor:color)
```
[3] attach to a material
```
let data = NSData(bytes: &uniforms, length: MemoryLayout<Uniforms>.size)
geo.firstMaterial?.setValue(data, forKey: "uniforms")
```
[4] use in shader!
```
fragment float4 flexFragment(SimpleVertex in [[stage_in]],
                          constant Uniforms& uniforms [[buffer(2)]]
                          )
{
    return float4(0.2*uniforms.uColor, 1.0);
}
```
to update uniforms, simply update the Uniform struct and repeat step [4]
see full project to understand more about how it all fits together, but this is the essence.


