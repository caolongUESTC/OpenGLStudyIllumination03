//
//  ViewController.m
//  OpenGLillumination03
//
//  Created by 曹龙 on 2020/9/4.
//  Copyright © 2020 曹龙. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()
@property (nonatomic, strong) OpenGLView *openGLView;
@end

@implementation ViewController
- (OpenGLView *)openGLView {
    if (!_openGLView) {
        _openGLView = [OpenGLView new];
        [self.view addSubview:_openGLView];
    }
    return _openGLView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.openGLView.frame = CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44);
}

@end
