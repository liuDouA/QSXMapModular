//
//  QSXMAPointAnnotation.h
//  Pods
//
//  Created by liudou on 2018/10/6.
//

#import <MAMapKit/MAMapKit.h>

@interface QSXMAPointAnnotation : MAPointAnnotation

/**
 大头针类型的标记
 0 本地位置
 1. 开始大头针
 2. 暂停大头针
 3. 再开始大头针
 4. 结束大头针
 
 */
@property(assign,nonatomic)NSInteger  typeFlage;

@end
