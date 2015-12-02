//
//  ViewController.m
//  AhaGesturePasswordDemo
//
//  Created by wei on 15/11/30.
//  Copyright © 2015年 livv. All rights reserved.
//

#import "ViewController.h"
#import "AhaGesturePasswordView.h"

#define UIColorFromHEX(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController () <AhaGesturePasswordDelegate>

@property (nonatomic, weak) IBOutlet UIImageView * avatar;
@property (nonatomic, weak) IBOutlet UILabel * msgLabel;
@property (nonatomic, weak) IBOutlet AhaGesturePasswordView * gpwdView;
@property (nonatomic, copy) NSString * pwdStr;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColorFromHEX(0x3a7a84);
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width * .5;
    self.avatar.layer.masksToBounds = YES;
    

    self.gpwdView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)actionReset:(id)sender {
    
    self.msgLabel.text = @"请输入手势密码";
    self.pwdStr = @"";
    [self.gpwdView reset];
}


#pragma mark - AhaGesturePasswordDelegate

- (void)ahaGesturePasswordView:(AhaGesturePasswordView *)gestureView password:(NSString *)pwd {
    
    NSLog(@"%@", pwd);
    
    if (self.pwdStr.length < 1) {
        
        self.pwdStr = pwd;
        self.msgLabel.text = @"请再输入一次手势密码";
        [gestureView reset];
        
    } else {
        
        if ([self.pwdStr isEqualToString:pwd]) {
            
            self.msgLabel.text = @"验证成功";
            //todo... 存储密码
            self.pwdStr = @"";
            [self.gpwdView reset];
            
        } else {
            
            self.msgLabel.text = @"两次输入的密码不一致";
            [gestureView setError];
        }
    }

}

@end
