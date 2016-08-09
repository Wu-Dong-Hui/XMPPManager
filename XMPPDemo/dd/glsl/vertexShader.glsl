//
//  vertexShader.glsl
//  Dong
//
//  Created by darkdong on 14-9-12.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

attribute vec4 position;
attribute vec4 inputPicTextureCoordinate;

varying vec2 picTextureCoordinate;

void main()
{
    gl_Position = position;
    picTextureCoordinate = inputPicTextureCoordinate.xy;
}
