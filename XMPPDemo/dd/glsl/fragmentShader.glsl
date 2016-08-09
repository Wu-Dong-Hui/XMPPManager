//
//  fragmentShader.glsl
//  Dong
//
//  Created by darkdong on 14-9-12.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

varying highp vec2 picTextureCoordinate;

uniform sampler2D picTexture;
uniform sampler2D lutTexture;
uniform int base;
uniform bool isLayoutHorizontally;

void main()
{
    //gl_FragColor = texture2D(picTexture, picTextureCoordinate);

    highp vec4 textureColor = texture2D(picTexture, picTextureCoordinate);
    
    highp float lutBase = float(base);
    
    highp float quadIndex = textureColor.b * (lutBase - 1.0);
    highp float gridDimension = 1.0 / lutBase;
    highp float pixelDimension = 1.0 / (lutBase * lutBase);
    
    highp vec2 lutTextureCoordinate1;
    highp vec2 lutTextureCoordinate2;
    
    if (isLayoutHorizontally) {
        //lut texture grid is arranged horizontally
        highp vec2 quad1;
        quad1.x = floor(quadIndex) * gridDimension;
        
        highp vec2 quad2;
        quad2.x = ceil(quadIndex) * gridDimension;
        
        highp float x = textureColor.r;
        highp float y = textureColor.g;
        
        lutTextureCoordinate1.x = quad1.x + pixelDimension * 0.5 + ((gridDimension - pixelDimension) * x);
        lutTextureCoordinate1.y = y;
        
        lutTextureCoordinate2.x = quad2.x + pixelDimension * 0.5 + ((gridDimension - pixelDimension) * x);
        lutTextureCoordinate2.y = y;
    }else {
        //lut texture grid is arranged vertically
        highp vec2 quad1;
        quad1.y = floor(quadIndex) * gridDimension;
        
        highp vec2 quad2;
        quad2.y = ceil(quadIndex) * gridDimension;
        
        highp float x = textureColor.r;
        highp float y = textureColor.g;
        
        lutTextureCoordinate1.x = x;
        lutTextureCoordinate1.y = quad1.y + pixelDimension * 0.5 + ((gridDimension - pixelDimension) * y);
        
        lutTextureCoordinate2.x = x;
        lutTextureCoordinate2.y = quad2.y + pixelDimension * 0.5 + ((gridDimension - pixelDimension) * y);
    }
    
    lowp vec4 newColor1 = texture2D(lutTexture, lutTextureCoordinate1);
    lowp vec4 newColor2 = texture2D(lutTexture, lutTextureCoordinate2);
    
    highp float a = fract(quadIndex);
    lowp vec4 newColor = mix(newColor1, newColor2, a);
    gl_FragColor = vec4(newColor.rgb, textureColor.w);
}
