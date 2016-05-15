//
//  ViewController.m
//  ObjcImageProcessingTest
//
//  Created by 劉柏賢 on 2016/5/9.
//  Copyright © 2016年 劉柏賢. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}


/**
 return r,g,b,a
 */
- (NSData*)getRGBAsFromImage:(UIImage*)image
{
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    self.width = width;
    self.height = height;
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
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
    rawData = NULL;
    
    CGColorSpaceRelease(colorSpace);
    
    return data;
}

- (void)setImageFromData:(NSData*)data width:(NSUInteger)width height:(NSUInteger)height destImage:(UIImage**)destImage
{
    Byte *rawData = (Byte *)data.bytes;
    CFIndex count = data.length;
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
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


- (void)process:(UIImage *)image destImage:(UIImage **)resultImage
{
    NSData *srcData = [self getRGBAsFromImage:image];
    Byte *srcPixels = (Byte*)srcData.bytes;
    Byte *destPixels = malloc(sizeof(Byte) * srcData.length);
    
    for (NSUInteger index = 0; index < srcData.length; index += 4)
    {
        NSUInteger r = index + 0;
        NSUInteger g = index + 1;
        NSUInteger b = index + 2;
        NSUInteger a = index + 3;
        
        Byte value = (srcPixels[r] + srcPixels[g] + srcPixels[b]) / 3.0;
        Byte color = value > 128 ? 255 : 0;
        destPixels[r] = color;
        destPixels[g] = color;
        destPixels[b] = color;
        destPixels[a] = srcPixels[a];
    }
    
    NSData *destData = [NSData dataWithBytesNoCopy:destPixels length:srcData.length freeWhenDone:YES];
    [self setImageFromData:destData width: self.width height: self.height destImage:resultImage];
}

- (IBAction)handler:(UIButton *)sender {
    
    
    CFTimeInterval startTime = CACurrentMediaTime();
    
    UIImage *image = self.sourceImageView.image;
    
    __weak ViewController *weakSelf = self;
    
    // Async
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *destImage;
        [self process:image destImage:&destImage];
        
        // UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.destImageView.image = destImage;
            
            double sec = CACurrentMediaTime() - startTime;
            
            weakSelf.timeLabel.text = [[NSString alloc] initWithFormat:@"耗時:%.3f秒", sec];
        });
        
    });
    
}

@end
