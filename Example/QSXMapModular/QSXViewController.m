//
//  QSXViewController.m
//  QSXMapModular
//
//  Created by liudouA on 09/13/2018.
//  Copyright (c) 2018 liudouA. All rights reserved.
//

#import "QSXViewController.h"
#import <QSXMapModular/SportsMapViewControlManager.h>
@interface QSXViewController ()

@end

@implementation QSXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(100, 110, 200, 40);
    btn2.backgroundColor = [UIColor greenColor];
    [btn2 addTarget:self action:@selector(btnStopClick) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"测试用啊 " forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(100, 180, 200, 40);
    btn3.backgroundColor = [UIColor greenColor];
    [btn3 addTarget:self action:@selector(showordismiss) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setTitle:@"控制地图展示消失啊 " forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    
    
    SportsMapViewControlManager   *manager =[SportsMapViewControlManager shareManager];
    [self.view addSubview:manager.view];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)btnStopClick{
    
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    [self.view setBackgroundColor:[UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]];
}
- (void)showordismiss{
    [SportsMapViewControlManager shareManager].view.hidden = ![SportsMapViewControlManager shareManager].view.hidden;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
