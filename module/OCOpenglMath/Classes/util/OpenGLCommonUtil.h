//
//  OpenGLCommonUtil.h
//  OCOpenGLMath
//
//  Created by 曹龙 on 2020/9/2.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

NS_ASSUME_NONNULL_BEGIN
static GLfloat PI = 3.1415926;
@interface OpenGLCommonUtil : NSObject
/*
*   生成OpenGL2.0环境
*
*  @return program
******/
+ (EAGLContext *)generateGL2Context;

/******
 *  设置EAGL参数
 *  @param eaglLayer 需要设置的layer
 *
 ****/
+ (void)setupEAGLLayer:(CAEAGLLayer *)eaglLayer;
@end

NS_ASSUME_NONNULL_END
