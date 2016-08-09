//
//  DDGLKit.swift
//  Dong
//
//  Created by darkdong on 15/4/9.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import GLKit

class DDGLKit {
    //名字要与 vertextShader.glsl 中的一致
    static var vertexShaderAttributePosition: String = "position"
    static var vertexShaderAttributeInputPicTextureCoordinate: String = "inputPicTextureCoordinate"
    
    static func printShaderLog(shader: GLuint) {
        var logLength: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            let pchar = UnsafeMutablePointer<GLchar>.alloc(Int(logLength))
            glGetShaderInfoLog(shader, logLength, &logLength, pchar)
            let msg = NSString(bytes: pchar, length: Int(logLength), encoding: NSUTF8StringEncoding)
            NSLog("Shader compile log: \(msg)")
            pchar.destroy()
        }
    }
    
    static func printProgramLog(program: GLuint) {
        var logLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            let pchar = UnsafeMutablePointer<GLchar>.alloc(Int(logLength))
            glGetProgramInfoLog(program, logLength, &logLength, pchar)
            let msg = NSString(bytes: pchar, length: Int(logLength), encoding: NSUTF8StringEncoding)
            NSLog("Program link log: \(msg)")
            pchar.destroy()
        }
    }
    static func compileShaderWithString(string: String!, type: GLenum) -> GLuint? {
        if string == nil {
            return nil
        }
        
        let shader = glCreateShader(type)
        let nsstring = string as NSString
        var source = nsstring.UTF8String
        glShaderSource(shader, 1, &source, nil)
        glCompileShader(shader)
        
        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if 0 == status {
            glDeleteShader(shader)
            return nil
        }else {
            return shader
        }
    }
    
    static func compileShaderWithFile(file: String!, type: GLenum) -> GLuint? {
        if file == nil {
            return nil
        }
        let nsstring = try? NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding)
        let string = nsstring as! String
        return self.compileShaderWithString(string, type: type)
    }
    
    static func linkProgram(program: GLuint) -> Bool {
        glLinkProgram(program)
        
        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if 0 == status {
            return false
        }else {
            return true
        }
    }
    
    static func prepareLutProgram(vertexShaderFile vertexShaderFile: String!, fragmentShaderFile: String!) -> GLuint? {
        // Create and compile vertex shader.
        let vshader = self.compileShaderWithFile(vertexShaderFile, type: GLenum(GL_VERTEX_SHADER))
        if vshader == nil {
            NSLog("Failed to compile vertex shader")
            return nil
        }
        let vertexShader = vshader!
        
        // Create and compile fragment shader.
        let fshader = compileShaderWithFile(fragmentShaderFile, type: GLenum(GL_FRAGMENT_SHADER))
        if fshader == nil {
            NSLog("Failed to compile fragment shader")
            return nil
        }
        let fragmentShader = fshader!
        
        // Create shader program.
        let program = glCreateProgram()
        
        // Attach vertex shader to program.
        glAttachShader(program, vertexShader)
        
        // Attach fragment shader to program.
        glAttachShader(program, fragmentShader)
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.Position.rawValue), vertexShaderAttributePosition)
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.TexCoord0.rawValue), vertexShaderAttributeInputPicTextureCoordinate)
        
        // Link program.
        if !linkProgram(program) {
            NSLog("Failed to link program: \(program)")
            
            if vertexShader != 0 {
                glDeleteShader(vertexShader)
            }
            if fragmentShader != 0 {
                glDeleteShader(fragmentShader)
            }
            if program != 0 {
                glDeleteProgram(program)
            }
            
            return nil
        }
        
        // Release vertex and fragment shaders.
        if vertexShader != 0 {
            glDetachShader(program, vertexShader)
            glDeleteShader(vertexShader)
        }
        if fragmentShader != 0 {
            glDetachShader(program, fragmentShader)
            glDeleteShader(fragmentShader)
        }
        
        return program
    }
}