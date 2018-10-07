//
//  SportsMapViewControlManager.h
//  Pods
//
//  Created by 刘豆 on 2018/9/13.
//

#import <UIKit/UIKit.h>
#import "AMapRouteRecord.h"

#define MYBUNDLE_NAME @ "QSXMapModular.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath:MYBUNDLE_PATH]

#define BundelImage(imageName) [UIImage imageNamed:imageName inBundle:MYBUNDLE compatibleWithTraitCollection:nil]

@interface SportsMapViewControlManager : UIViewController
+ (SportsMapViewControlManager *) shareManager;
@property(strong,nonatomic)AMapRouteRecord *mapShowCod;
@end
