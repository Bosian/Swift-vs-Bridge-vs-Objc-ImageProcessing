//
//  ViewController.h
//  ObjcImageProcessingTest
//
//  Created by 劉柏賢 on 2016/5/9.
//  Copyright © 2016年 劉柏賢. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *destImageView;

- (IBAction)handler:(UIButton *)sender;

@end

