//
//  DDLutController.swift
//  Dong
//
//  Created by darkdong on 14-9-16.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import GLKit

extension UIImage {
    func imageByApplyingLutImage(lutImage: UIImage?) -> UIImage? {
        if let lutImage = lutImage {
            let vc = DDLutController(picImage: self, lutImage: lutImage)
            
            let isLutLayoutHorizontally = lutImage.size.width > lutImage.size.height
            let length = isLutLayoutHorizontally ? lutImage.size.width: lutImage.size.height
            let base = Int(sqrt(length * lutImage.scale))
            
            vc.lutBase = base
            vc.isLutLayoutHorizontally = isLutLayoutHorizontally
            
            return vc.filteredImage()
        }else {
            return self
        }
    }
}

class DDLutController: UIViewController, GLKViewDelegate {
    
    struct Static {
        static let vertexShaderFileName = "vertexShader"
        static let fragmentShaderFileName = "fragmentShader"
        static let shaderExtName = "glsl"
        
        //名字要与 fragmentShader.glsl 中的一致
        static let glUniformNamePicTexture = "picTexture"
        static let glUniformNameLutTexture = "lutTexture"
        static let glUniformNameBase = "base"
        static let glUniformNameIsLayoutHorizontally = "isLayoutHorizontally"
    }
    
    struct Position {
        var x: Float
        var y: Float
        var z: Float
    }
    
    struct TextureCoordinate {
        var x: Float
        var y: Float
    }
    
    struct Vertex {
        var position: Position
        var textureCoordinate: TextureCoordinate
    }

    let vertecis = [
        Vertex(position: Position(x: -1, y: 1, z: -1), textureCoordinate: TextureCoordinate(x: 0, y: 0)),
        Vertex(position: Position(x: -1, y: -1, z: -1), textureCoordinate: TextureCoordinate(x: 0, y: 1)),
        Vertex(position: Position(x: 1, y: 1, z: -1), textureCoordinate: TextureCoordinate(x: 1, y: 0)),
        Vertex(position: Position(x: 1, y: -1, z: -1), textureCoordinate: TextureCoordinate(x: 1, y: 1)),
    ]
    
    var glView: GLKView!
    var lutBase = 16
    var isLutLayoutHorizontally = true
    var context: EAGLContext = {
        let context = EAGLContext(API: .OpenGLES2)
        if #available(iOS 7.1, *) {
            context.multiThreaded = true
        } else {
            // Fallback on earlier versions
        }
        return context
    }()
    var program: GLuint = 0
    var vertexArrayBuffer: GLuint = 0
    
    var picImage: UIImage!
    var lutImage: UIImage!
    
    convenience init(picImage: UIImage!, lutImage: UIImage!) {
        self.init()
        
        self.picImage = picImage
        self.lutImage = lutImage
    }
    
    override func viewDidLoad() {
//        NSLog("DDLutController viewDidLoad main? \(NSThread.isMainThread())")
//        NSLog("DDLutController picImage \(picImage.size) \(picImage.scale)")
        let scale = picImage.scale / 2
        let picSize = CGSizeApplyAffineTransform(picImage.size, CGAffineTransformMakeScale(scale, scale))
//        let picSize = picImage.size
        let picRect = CGRect(origin: CGPointZero, size: picSize)
        glView = GLKView(frame: picRect, context: context)
        glView.delegate = self
//        view.addSubview(glView)
        
        setupGL()
    }
    
    deinit {
//        NSLog("DDLutController deinit main? \(NSThread.isMainThread())")
        teardownGL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if isViewLoaded() && view.window != nil {
            teardownGL()
        }
    }
    
    //MARK: - GLKViewDelegate
    func glkView(view: GLKView, drawInRect rect: CGRect) {
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(vertecis.count))
    }
    
    //MARK: - public
    func filteredImage() -> UIImage? {
        if UIApplication.sharedApplication().applicationState == .Active {
            if !isViewLoaded() {
                //load view
                _ = self.view
            }
            return glView.snapshot
        }else {
            return nil
        }
    }
    
    private // MARK:- private
    
    func loadTextureFromImage(image: UIImage!) -> GLKTextureInfo! {
        var textureInfo = try? GLKTextureLoader.textureWithCGImage(image.CGImage!, options: nil)
        if textureInfo == nil {
            let regularizedImage = image.imageByPNGRepresentation()
            textureInfo = try? GLKTextureLoader.textureWithCGImage(regularizedImage.CGImage!, options: nil)
        }
        return textureInfo
    }
    
    func setupGL() {
        EAGLContext.setCurrentContext(context)
        
        let vshaderFile = NSBundle.mainBundle().pathForResource(Static.vertexShaderFileName, ofType: Static.shaderExtName)
        let fshaderFile = NSBundle.mainBundle().pathForResource(Static.fragmentShaderFileName, ofType: Static.shaderExtName)
        if let prog = DDGLKit.prepareLutProgram(vertexShaderFile: vshaderFile, fragmentShaderFile: fshaderFile) {
//            DDLog2.print("setupGL main? \(NSThread.isMainThread())")
            program = prog
//            glEnable(GLenum(GL_TEXTURE))
            
            glGenBuffers(1, &vertexArrayBuffer)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexArrayBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(Vertex) * vertecis.count, vertecis, GLenum(GL_STATIC_DRAW))
            
            let offsetZero: UnsafePointer<Void> = nil
            
            let VertexAttribPosition = GLuint(GLKVertexAttrib.Position.rawValue)
            glEnableVertexAttribArray(VertexAttribPosition)
            glVertexAttribPointer(VertexAttribPosition, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), offsetZero)
            
            let VertexAttribTexCoord0 = GLuint(GLKVertexAttrib.TexCoord0.rawValue)
            glEnableVertexAttribArray(VertexAttribTexCoord0)
            let texCoordOffset: UnsafePointer<Void> = offsetZero + sizeof(Position)
            glVertexAttribPointer(VertexAttribTexCoord0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Vertex)), texCoordOffset)
            
            //Before pass uniforms to program, we must use program
            glUseProgram(program)
            
            //pass uniform parameters to shader.
            glActiveTexture(GLenum(GL_TEXTURE0))
            glUniform1i(glGetUniformLocation(program, Static.glUniformNamePicTexture), 0)
            let picInfo = loadTextureFromImage(picImage)
            glBindTexture(picInfo.target, picInfo.name)

            glActiveTexture(GLenum(GL_TEXTURE1))
            glUniform1i(glGetUniformLocation(program, Static.glUniformNameLutTexture), 1)
            let lutInfo = loadTextureFromImage(lutImage)
            glBindTexture(lutInfo.target, lutInfo.name)
            
            glUniform1i(glGetUniformLocation(program, Static.glUniformNameBase) , GLint(lutBase));
            glUniform1i(glGetUniformLocation(program, Static.glUniformNameIsLayoutHorizontally) , GLint(Int(isLutLayoutHorizontally)));
        }
    }
    
    func teardownGL() {
        EAGLContext.setCurrentContext(context)

        glDeleteBuffers(1, &vertexArrayBuffer)
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
        
        EAGLContext.setCurrentContext(nil)
    }
}