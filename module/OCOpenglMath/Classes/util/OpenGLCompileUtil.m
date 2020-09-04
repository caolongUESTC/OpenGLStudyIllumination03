//
//  OpenGLCompileUtil.m
//  OCOpenGLMath
//
//  Created by 曹龙 on 2020/9/2.
//

#import "OpenGLCompileUtil.h"
#import <OpenGLES/ES2/gl.h>

@implementation OpenGLCompileUtil
- (GLuint)loadShaders: (NSString *)vert fragment:(NSString *)frag {
    GLuint vertShader, fragShader;
    GLint program = glCreateProgram(); //创建程序。
    if(vert == nil || frag == nil || vert.length == 0 || frag.length == 0) {
        NSLog(@"输入的着色器内容为空");
        exit(1);
    }
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    //清理资源
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    NSString *content = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint compileResult = GL_TRUE;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &compileResult); //获取编译结果
    if(compileResult == GL_FALSE) {
        GLchar errorLog[1024] = {0};
        GLsizei logLen = 0;
        glGetShaderInfoLog(*shader, sizeof(errorLog), &logLen, &errorLog[0]);
        NSString *error = [NSString stringWithUTF8String:errorLog];
        NSLog(@"compileError: %@",error);
        exit(1); //报错退出
    }
}

- (GLint)linkProgram:(GLuint)program; {
    glLinkProgram(program); //链接程序
    GLint linkResult;
    glGetProgramiv(program, GL_LINK_STATUS, &linkResult);
    
    if (linkResult == GL_FALSE) {
        GLchar messageArr[256];
        glGetProgramInfoLog(program, sizeof(messageArr), 0, &messageArr[0]);
        NSString *errorMessage = [NSString stringWithUTF8String:messageArr];
        NSLog(@"error%@", errorMessage);
        return linkResult;
    }
    return linkResult;
}

@end
