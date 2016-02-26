//
//  TenonPlugin.h
//  Tenon
//
//  Created by leqicheng on 15/8/7.
//  Copyright © 2015年 乐其橙. All rights reserved.
//


#import <Tenon/CDVPlugin.h>

@interface TenonPlugin : CDVPlugin

- (void)evaluateJSFromLocal:(CDVInvokedUrlCommand*)command;

@end
