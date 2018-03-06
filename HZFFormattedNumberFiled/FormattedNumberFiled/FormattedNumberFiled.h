//
//  FormattedNumberFiled.h
//  会找房
//
//  Created by 王梦思 on 2017/11/22.
//  Copyright © 2017年 会分期. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+NumberFormat.h"

@interface FormattedNumberFiled : UITextField

@property (copy, readwrite, nonatomic) NSString *format;
@property (copy, readonly, nonatomic) NSString *unformattedText;

- (NSString *)string:(NSString *)string withNumberFormat:(NSString *)format __attribute__ ((deprecated));

@end
