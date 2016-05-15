//
//  ImageProcessing.h
//  ImageProcessingIOS
//
//  Created by Air on 2014/11/7.
//  Copyright (c) 2014年 Bosian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageProcessing : NSObject

+ (NSData*)getRGBAsFromImage:(UIImage*)image;
+ (void)setImageFromData:(NSData*)data width:(NSUInteger)width height:(NSUInteger)height destImage:(UIImage**)destImage;
+ (void)fixrotation:(UIImage **)image;

@end
