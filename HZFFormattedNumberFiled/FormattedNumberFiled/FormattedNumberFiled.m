//
//  FormattedNumberFiled.m
//  会找房
//
//  Created by 王梦思 on 2017/11/22.
//  Copyright © 2017年 会分期. All rights reserved.
//

#import "FormattedNumberFiled.h"

@interface FormattedNumberFiled () <UITextFieldDelegate>

@property (copy, readwrite, nonatomic) NSString *currentFormattedText;
@property (nonatomic, weak) id<UITextFieldDelegate> originalDelegate;

@end

@implementation FormattedNumberFiled

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    self.keyboardType = UIKeyboardTypeNumberPad;
    [super setDelegate:self];
    [self addTarget:self action:@selector(formatInput:) forControlEvents:UIControlEventEditingChanged];
}

- (NSString *)string:(NSString *)string withNumberFormat:(NSString *)format
{
    if (!string)
        return @"";
    
    return [string re_stringWithNumberFormat:format];
}

- (void)formatInput:(UITextField *)textField
{
    // If it was not deleteBackward event
    //
    if (![textField.text isEqualToString:self.currentFormattedText]) {
        __typeof (self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __typeof (self) __strong strongSelf = weakSelf;
            textField.text = [strongSelf.unformattedText re_stringWithNumberFormat:strongSelf.format];
            strongSelf.currentFormattedText = textField.text;
            [strongSelf sendActionsForControlEvents:UIControlEventEditingChanged];
        });
    }
}

- (void)deleteBackward
{
    NSInteger decimalPosition = -1;
    for (NSInteger i = self.text.length - 1; i > 0; i--) {
        NSString *c = [self.format substringWithRange:NSMakeRange(i - 1, 1)];
        
        if ([c isEqualToString:@"X"]) {
            decimalPosition = i;
            break;
        }
    }
    
    if (decimalPosition == -1) {
        self.text = @"";
    } else {
        self.text = [self.text substringWithRange:NSMakeRange(0, decimalPosition)];
    }
    
    self.currentFormattedText = self.text;
    
    //Since iOS6 the UIControlEventEditingChanged is not triggered by programmatically changing the text property of UITextField.
    //
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (NSString *)unformattedText
{
    if (!self.format) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:NSRegularExpressionCaseInsensitive error:NULL];
        return [regex stringByReplacingMatchesInString:self.text options:0 range:NSMakeRange(0, self.text.length) withTemplate:@""];
    }
    NSString *trimmedFromat = [[self.format componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789X"] invertedSet]] componentsJoinedByString:@""];
    NSString *trimmedText = [[self.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSMutableString *unformattedText = [NSMutableString string];
    NSUInteger length = MIN([trimmedFromat length], [trimmedText length]);
    
    for (NSUInteger i = 0; i < length; ++i) {
        NSRange range = NSMakeRange(i, 1);
        
        NSString *symbol = [trimmedText substringWithRange:range];
        if (![[trimmedFromat substringWithRange:range] isEqualToString:symbol]) {
            [unformattedText appendString:symbol];
        }
    }
    
    return [unformattedText copy];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 1 && string.length==0) {
        [self deleteBackward];
        return NO;
    }
    
    if ([self.originalDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.originalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

#pragma mark -
#pragma mark Custom setters / getters

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    [self willChangeValueForKey:@"delegate"];
    self.originalDelegate = delegate;
    [self didChangeValueForKey:@"delegate"];
}

- (id<UITextFieldDelegate>)delegate
{
    return self.originalDelegate;
}

#pragma mark -
#pragma mark NSObject method overrides

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.originalDelegate respondsToSelector:aSelector] && self.originalDelegate != self) {
        return self.originalDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL respondsToSelector = [super respondsToSelector:aSelector];
    
    if (!respondsToSelector && self.originalDelegate != self) {
        respondsToSelector = [self.originalDelegate respondsToSelector:aSelector];
    }
    return respondsToSelector;
}

@end
