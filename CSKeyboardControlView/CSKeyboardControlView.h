//
//  CSKeyboardControlView.h
//  Whiteboard
//
//  Created by Hector Zhao on 10/28/11.
//  Copyright (c) 2011 Greengar Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

// comment this to turn off debug messages:
#define CSDebug 1

#if CSDebug
#   define CSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define CSLog(...)
#endif

#define kKeyboardHeight 216
#define kKeyboardControlHeight 44

@interface CSKeyboardControlView : UIView {
    UIImageView      *backgroundView;
    NSMutableArray   *registeredViewArray;
    NSMutableArray   *registeredActionArray;
}

+ (void) showWithObject:(id)object withCallbackForCancel:(SEL)cancelCallback withCallbackForDo:(SEL)doCallback;
+ (void) showInView:(UIView *)view withObject:(id)object withCallbackForCancel:(SEL)cancelCallback withCallbackForDo:(SEL)doCallback;
+ (void) registerDismissActionForUIControl:(UIControl *)control;
+ (void) registerDismissActionForUIControl:(UIControl *)control withUIControlEvent:(UIControlEvents )event;
+ (void) dismiss;

@end
