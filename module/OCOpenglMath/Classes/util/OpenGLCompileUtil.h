//
//  OpenGLCompileUtil.h
//  OCOpenGLMath
//
//  Created by 曹龙 on 2020/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLCompileUtil : NSObject
/*
 * glcompileShader(编译)、glAttachShader(关联)、glLinkProgram(链接)
 *  @param vertex 顶点着色器
 *  @param fragment 片段着色器
 *
 *  @return program
 ******/
- (GLuint)loadShaders: (NSString *)vert fragment:(NSString *)frag;

/**
 * 编译shader
 *  @param shader (inout) 返回生成的shader
 *  @param type 着色器的类型
 *  @param file 着色器文件地址
 *
 *******************/
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;

/**
 *  链接程序
 *  @param program 需要链接的程序
 *
 *  @return
 **************/
- (GLint)linkProgram:(GLuint)program;
@end

NS_ASSUME_NONNULL_END
