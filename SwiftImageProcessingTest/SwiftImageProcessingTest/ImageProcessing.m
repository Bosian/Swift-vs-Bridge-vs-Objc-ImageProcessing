//
//  ImageProcessing.m
//  ImageProcessingIOS
//
//  Created by Air on 2014/11/7.
//  Copyright (c) 2014年 Bosian. All rights reserved.
//
#import "ImageProcessing.h"

@implementation ImageProcessing

const NSUInteger bitsPerComponent = 8;
const NSUInteger bytesPerPixel = 4;

/**
 return r,g,b,a
 */
+ (NSData*)getRGBAsFromImage:(UIImage*)image
{
    [self fixrotation:&image];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger size = height * width * bytesPerPixel;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    Byte *rawData = (Byte*) calloc(size, sizeof(Byte));
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    NSData *data = [NSData dataWithBytes:rawData length:size];
    
    CGContextRelease(context);
    free(rawData);
    CGColorSpaceRelease(colorSpace);


    
    return data;
}

+ (void)setImageFromData:(NSData*)data width:(NSUInteger)width height:(NSUInteger)height destImage:(UIImage**)destImage
{
    Byte *rawData = (Byte *)data.bytes;
    CFIndex count = data.length;
    NSUInteger bytesPerRow = bytesPerPixel * width;

    CFDataRef rgbData = CFDataCreate(NULL, rawData, count);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(rgbData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        bitsPerComponent,
                                        bytesPerPixel * bitsPerComponent,
                                        bytesPerRow,
                                        colorSpace,
                                        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
                                        provider,
                                        nil,
                                        NO,
                                        kCGRenderingIntentDefault);
    
    *destImage = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(rgbData);
}

+ (void)fixrotation:(UIImage **)image
{
    if ((*image).imageOrientation != UIImageOrientationUp)
    {
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        switch ((*image).imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, (*image).size.width, (*image).size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
                break;
                
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                transform = CGAffineTransformTranslate(transform, (*image).size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
                break;
                
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, (*image).size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
        
        switch ((*image).imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, (*image).size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
                
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, (*image).size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        CGContextRef ctx = CGBitmapContextCreate(NULL, (*image).size.width, (*image).size.height,
                                                 CGImageGetBitsPerComponent((*image).CGImage), 0,
                                                 CGImageGetColorSpace((*image).CGImage),
                                                 CGImageGetBitmapInfo((*image).CGImage));
        
        CGContextConcatCTM(ctx, transform);
        
        switch ((*image).imageOrientation)
        {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(ctx, CGRectMake(0,0,(*image).size.height,(*image).size.width), (*image).CGImage);
                break;
                
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,(*image).size.width,(*image).size.height), (*image).CGImage);
                break;
        }
        
        // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        
        *image = img;
    }
}

@end
