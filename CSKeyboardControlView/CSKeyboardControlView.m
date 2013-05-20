//
//  CSKeyboardControlView.m
//  Whiteboard
//
//  Created by Hector Zhao on 10/28/11.
//  Copyright (c) 2011 Greengar Studios. All rights reserved.
//

#import "CSKeyboardControlView.h"

@interface CSKeyboardControlView ()

- (void) showInView:(UIView *)view withObject:(id)object withCallbackForCancel:(SEL)cancelCallback withCallbackForDo:(SEL)doCallback;
- (void) registerDismissActionForUIControl:(UIControl *)control withUIControlEvent:(UIControlEvents )event;
- (void) hideKeyboard:(UIView *)view;
- (void) dismissKeyboard;
- (void) dismissControl;
- (void) dismiss;
- (void) memoryWarning:(NSNotification*)notification;

@end

static CSKeyboardControlView *sharedView = nil;

@implementation CSKeyboardControlView

+ (CSKeyboardControlView *)sharedView {
	
	if(sharedView == nil)
		sharedView = [[CSKeyboardControlView alloc] initWithFrame:CGRectZero];
	
	return sharedView;
}

+ (void)showWithObject:(id)object withCallbackForCancel:(SEL)cancelCallback withCallbackForDo:(SEL)doCallback {
    [CSKeyboardControlView showInView:nil withObject:object withCallbackForCancel:cancelCallback withCallbackForDo:doCallback];
}

+ (void)showInView:(UIView *)view withObject:(id)object withCallbackForCancel:(SEL)cancelCallback withCallbackForDo:(SEL)doCallback {
    
//    BOOL addingToWindow = NO;
    
    if (object == nil || cancelCallback == nil || doCallback == nil) {
        CSLog(@"Please make sure that callbacks for cancel and do are not set");
        return;
    }
    
    if(!view) {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
//        addingToWindow = YES;
        
        if ([keyWindow respondsToSelector:@selector(rootViewController)]) {
            //Use the rootViewController to reflect the device orientation
            view = keyWindow.rootViewController.view;
        }
        
        if(view == nil) 
            view = keyWindow;
    }
    
	[[CSKeyboardControlView sharedView] showInView:view withObject:object withCallbackForCancel:cancelCallback withCallbackForDo:doCallback];
}

+ (void) registerDismissActionForUIControl:(UIControl *)control {
    if ([control isKindOfClass:[UIButton class]]) {
        [[CSKeyboardControlView sharedView] registerDismissActionForUIControl:control withUIControlEvent:UIControlEventTouchUpInside];
    } else {
        [[CSKeyboardControlView sharedView] registerDismissActionForUIControl:control withUIControlEvent:UIControlEventValueChanged];
    }
}

+ (void) registerDismissActionForUIControl:(UIControl *)control withUIControlEvent:(UIControlEvents)event {
    [[CSKeyboardControlView sharedView] registerDismissActionForUIControl:control withUIControlEvent:event];
}

+ (void) dismiss {
    [[CSKeyboardControlView sharedView] dismiss];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backgroundView = nil;
        
        registeredViewArray = [[NSMutableArray alloc] init];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(memoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Instance method
#define kButtonWidth 69
#define kButtonHeight 36
- (void) showInView:(UIView *)view withObject:(id)object withCallbackForCancel:(SEL)cancelCallback withCallbackForDo:(SEL)doCallback {
    
    // Don't add more than 1 Keyboard Control to the view
    // Dismiss the previous one
    if (backgroundView != nil) {
        if ([backgroundView superview]) {
            [self dismissControl];
        }
    }
    
    // Add background
    CGRect viewFrame = CGRectMake(0, view.frame.size.height - kKeyboardHeight - kKeyboardControlHeight, view.frame.size.width, kKeyboardControlHeight);
    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background_Bar"]];
    [backgroundView setFrame:viewFrame];
    [backgroundView setUserInteractionEnabled:YES];
    [view addSubview:backgroundView];
        
    // Add cancel button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect cancelButtonFrame = CGRectMake(4, 3, kButtonWidth, kButtonHeight);
    [cancelButton setFrame:cancelButtonFrame];
    [cancelButton setImage:[UIImage imageNamed:@"Cancel_Button"] forState:UIControlStateNormal];
    [cancelButton addTarget:object action:cancelCallback forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:cancelButton];
    
    // Add done button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect doneButtonFrame = CGRectMake(backgroundView.frame.size.width - 4 - kButtonWidth, 3, kButtonWidth, kButtonHeight);
    [doneButton setFrame:doneButtonFrame];
    [doneButton setImage:[UIImage imageNamed:@"Done_Button"] forState:UIControlStateNormal];
    [doneButton addTarget:object action:doCallback forControlEvents:UIControlEventTouchUpInside];
    [doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:doneButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dismiss) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
        
}

- (void) registerDismissActionForUIButton:(UIButton *)button withUIControlEvent:(UIControlEvents)event {
    NSNumber *eventObject = [NSNumber numberWithInt:event];
    [registeredViewArray addObject:button];
    [registeredActionArray addObject:eventObject];
    [button addTarget:self action:@selector(dismiss) forControlEvents:event];
}

- (void) registerDismissActionForUIControl:(UIControl *)control withUIControlEvent:(UIControlEvents)event {
    NSNumber *eventObject = [NSNumber numberWithInt:event];
    [registeredViewArray addObject:control];
    [registeredActionArray addObject:eventObject];
    [control addTarget:self action:@selector(dismiss) forControlEvents:event];
}

- (void) hideKeyboard:(UIView *)view {
    for (UIView *subView in view.subviews) {
        [subView resignFirstResponder];
        [self hideKeyboard:subView];
    }
}

- (void) dismissControl {
    [backgroundView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
}

- (void) dismissKeyboard {
    [self hideKeyboard:[backgroundView superview]];
}

- (void) dismiss {
    if (backgroundView != nil && [backgroundView superview]) {
        [self dismissKeyboard];
        [self dismissControl];
    }
    
    if (registeredViewArray != nil) {
        for (int i = 0; i < [registeredViewArray count]; i++) {
            NSNumber *eventObject = (NSNumber *)[registeredActionArray objectAtIndex:i];
            UIControl *control = (UIControl *) [registeredViewArray objectAtIndex:i];
            [control removeTarget:self action:@selector(dismiss) forControlEvents:[eventObject intValue]];
            [registeredActionArray removeObjectAtIndex:i];
            [registeredViewArray removeObjectAtIndex:i];
        }
    }
    backgroundView = nil;
}

#pragma mark - MemoryWarning
- (void)memoryWarning:(NSNotification *)notification {
	
    if (sharedView.superview == nil) {
#if __has_feature(objc_arc)
#else
        [sharedView release];
#endif
        
        sharedView = nil;
    }
}

@end
