//
//  OpenGLCommonUtil.m
//  OCOpenGLMath
//
//  Created by 曹龙 on 2020/9/2.
//

#import "OpenGLCommonUtil.h"

@implementation OpenGLCommonUtil

+ (EAGLContext *)generateGL2Context {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    return context;
}

+ (void)setupEAGLLayer:(CAEAGLLayer *)eaglLayer {
    eaglLayer.opaque = YES; //设置为不透明
    NSDictionary *dict = @{kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
                              kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8}; //使用rgba8展示 不保留
    eaglLayer.drawableProperties = dict;
}

@end
