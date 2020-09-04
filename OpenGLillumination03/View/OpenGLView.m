//
//  OpenGLView.m
//  OpenGLillumination03
//
//  Created by 曹龙 on 2020/8/26.
//  Copyright © 2020 曹龙. All rights reserved.
//

#import "OpenGLView.h"
#import "OCOpenGLMath-umbrella.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGLView()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, assign) GLuint programId; //程序

//MARK: -- 缓存空间
@property (nonatomic, assign) GLuint colorRenderBufferId; //渲染缓存
@property (nonatomic, assign) GLuint colorFrameBufferId;    //帧缓存
@property (nonatomic, assign) GLuint depthRenderBufferId; //深度缓冲


@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation OpenGLView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        self.eaglLayer = (CAEAGLLayer *)self.layer;
        [OpenGLCommonUtil setupEAGLLayer:self.eaglLayer];
        self.context = [OpenGLCommonUtil generateGL2Context];
    }
    return self;
}
+ (Class)layerClass {
    return [CAEAGLLayer class];
}
//MARK: -- 初始化缓存
- (void)generateColorRenderBufferId {
    glGenBuffers(1, &_colorRenderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBufferId);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}
////创建深度缓冲区
- (void)generateDepthBufferId {
    int depthWidth,depthHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &depthWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &depthHeight);
    glGenRenderbuffers(1, &_depthRenderBufferId);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBufferId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, depthWidth, depthHeight);
}
- (void)generateColorFrameBufferId {
    glGenFramebuffers(1, &_colorFrameBufferId);
    glBindFramebuffer(GL_FRAMEBUFFER, _colorFrameBufferId);

    // Attach color render buffer and depth render buffer to frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBufferId);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, _depthRenderBufferId);

    // Set color render buffer as current render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBufferId);
}

- (void)setupRenderBuffer {
    [self generateColorRenderBufferId];
    [self generateDepthBufferId];
    [self generateColorFrameBufferId];
    // Check FBO satus
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Error: Frame buffer is not completed.");
        exit(1);
    }
}

- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_colorFrameBufferId);
    self.colorFrameBufferId = 0;
    glDeleteRenderbuffers(1, &_colorRenderBufferId);
    self.colorRenderBufferId = 0;
    glDeleteRenderbuffers(1, &_depthRenderBufferId);
    self.depthRenderBufferId = 0;
}

//MARK: - 系统回调
- (void)layoutSubviews {
    [super layoutSubviews];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self render];
}
//MARK: -- 渲染
- (void)render {
    //清屏
    [self clearScreen];
    //加载shader
    [self compileAndLink];
    for (int i = 0; i < 2 ; i++) {
        float offsetX = i == 0 ? 0 : 1;
        GLKMatrix4 model = GLKMatrix4Rotate(GLKMatrix4Translate(GLKMatrix4Identity, offsetX, 0, 0), 45*PI/180, 0, 1, 0);
        //发送数据到gpu
        [self postMessageToGPU:model];
        //绘制
        [self glDrawPhoto];
    }
}

//1.清除屏幕内容。
- (void)clearScreen {
    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 1.0, 1.0, 1.0); //将背景颜色设置为对应颜色,对应元素 r g b a。
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    CGFloat scale= [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale,
               self.frame.size.width * scale, self.frame.size.height * scale); //设置视口大小
   
}

//2.编译和链接程序。
- (void)compileAndLink {
    OpenGLCompileUtil *util = [[OpenGLCompileUtil alloc] init];
    
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@"vsh"]; //顶点着色器。
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"fsh"];//片段着色器。
    self.programId = [util loadShaders:vertFile fragment:fragFile];
    if ([util linkProgram:self.programId] == GL_FALSE) {
        return; //编译流程产生了错误。
    }
    glUseProgram(self.programId); //使用程序
}

//3.数据发送。将数据从CPU -> GPU
- (void)postMessageToGPU:(GLKMatrix4)modelMatrix {
    [self postVBOToGPU];
    
    //2.对shader里面的变量进行赋值。
    GLuint modelLoc = glGetUniformLocation(self.programId, "model"); //模型矩阵变量
    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, modelMatrix.m);

    GLuint viewLoc = glGetUniformLocation(self.programId, "view");//观察矩阵变量
    //观察矩阵可以通过lookat来创建
    GLKMatrix4 vMatrix = GLKMatrix4MakeLookAt(0, 0, 10, 0, 0, 0, 0, 1, 0); //通过相同的视角来查看
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, vMatrix.m);

    GLuint projectionLoc = glGetUniformLocation(self.programId, "projection"); //投影矩阵
    GLKMatrix4 projection = GLKMatrix4MakePerspective(PI/4, self.frame.size.width / self.frame.size.height, 0.1, 100);
    glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, projection.m);

    //片段着色器 fsh
    GLuint lightColorLoc = glGetUniformLocation(self.programId, "lightColor");
    glUniform3f(lightColorLoc, 1.0, 0.5, 0.3);
    GLuint objectColorLoc = glGetUniformLocation(self.programId, "objectColor");
    glUniform3f(objectColorLoc, 1.0, 1.0, 1.0);
    GLuint lightPosLoc = glGetUniformLocation(self.programId, "lightPos"); //光源距离
    glUniform3f(lightPosLoc, 0, 0, 4);

}

//postVBO
- (void)postVBOToGPU {
    GLfloat attrArr[] = {
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,

        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,

        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,

        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,

        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
        
    };
       
       //顶点着色器 vsh
       GLuint attrBuffer;
       glGenBuffers(1, &attrBuffer); //申请一个顶点数组。
       glBindBuffer(GL_ARRAY_BUFFER, attrBuffer); //bind cpu<->gpu
       glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW); //将数据发送到gpu
       
       //将前面传过去的数据 解释成变量。
       GLuint position = glGetAttribLocation(self.programId, "position"); //为vsh 生成变量。
       glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);//解释获取方式。
       glEnableVertexAttribArray(position); //使用变量。
    
    GLuint normal = glGetAttribLocation(self.programId, "normal"); //
    glVertexAttribPointer(normal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLvoid *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(normal);
}

- (void)glDrawPhoto {
    glDrawArrays(GL_TRIANGLES, 0, 36); //使用openGL将图像绘制出来。
    [self.context presentRenderbuffer:GL_RENDERBUFFER]; //将renderBuffer 的内容展现出来。
}


@end
