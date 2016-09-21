//
//  ViewController.m
//  MainWindowDemo
//
//  Created by Juncheng Han on 9/20/16.
//  Copyright © 2016 Theohzoneinc. All rights reserved.
//

#import "MainViewDemoViewController.h"

typedef enum CurrentView {
    ZONE_VIEW = 1,
    CHAT_VIEW = 2,
    FEED_VIEW = 3
}CurrentView;


@interface MainViewDemoViewController () <CAAnimationDelegate>
{
    UIView *zoneView;
    UIView *zoneBottomView;
    UIImageView *clothImageView;
    
    
    UIView *chatView;
    UIView *chatBottomView;
    
    UIVisualEffect *blurEffect;
    UIVisualEffectView *visualEffectView;
    
    UIView *leftSideView;
    UIView *rightSideView;
    
    UIView *feedView;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    UIPanGestureRecognizer *panG;
    
    UIPanGestureRecognizer *dragCloth;
    
    CurrentView currentView;
    
    UIImageView *dummyView;
    
    UIView *chatContainerView;
    UITextView *chatInputTxtView;
    UIButton *sendButton;
    
    CGFloat deltaY;
    CGPoint originalChatContainerCenter;
}
@end

@implementation MainViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    currentView = ZONE_VIEW;

    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    dragCloth = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragClothPanGesture:)];
    
    [self.view addGestureRecognizer:panG];

    
    
    [self layout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillOpen:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillClose:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidClose:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
//    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(keyboardWillChangeFrame:)
//                                                     name:UIKeyboardWillChangeFrameNotification
//                                                   object:nil];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layout {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    [self layoutZoneViewW:screenWidth viewH:screenHeight];
    [self layoutFeedViewW:screenWidth viewH:screenHeight];
    [self layoutChatViewW:screenWidth viewH:screenHeight];
    
    
}

- (void)layoutZoneViewW:(CGFloat)viewW viewH:(CGFloat)viewH {
    
    zoneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    zoneView.backgroundColor = [UIColor redColor];
    zoneView.tag = ZONE_VIEW;
    
    leftSideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, viewH)];
    leftSideView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    leftSideView.alpha = 0.0;
    
    rightSideView = [[UIView alloc] initWithFrame:CGRectMake(viewW - 50, 0, 50, viewH)];
    rightSideView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    rightSideView.alpha = 0.0;
    
    chatContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH - 50, viewW, 50)];
    chatContainerView.backgroundColor = [UIColor whiteColor];
    
    chatContainerView.alpha = 0.0;
    
    chatInputTxtView = [[UITextView alloc] initWithFrame:CGRectMake(8, 0, 200, 40)];
    chatInputTxtView.center = CGPointMake(chatInputTxtView.center.x, 50/2.0);
    chatInputTxtView.backgroundColor = [UIColor lightGrayColor];
    chatInputTxtView.textColor = [UIColor blackColor];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    sendButton.frame = CGRectMake(viewW - 8 - 50, 0, 50, 40);
    sendButton.center = CGPointMake(sendButton.center.x, 50/2.0);
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [chatContainerView addSubview:chatInputTxtView];
    [chatContainerView addSubview:sendButton];
    
    
    clothImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cloth"]];
    clothImageView.contentMode = UIViewContentModeScaleAspectFit;
    clothImageView.center = zoneView.center;
    clothImageView.userInteractionEnabled = YES;
    [clothImageView addGestureRecognizer:dragCloth];
    

    [zoneView addSubview:clothImageView];
    [zoneView addSubview:leftSideView];
    [zoneView addSubview:rightSideView];
    [zoneView addSubview:chatContainerView];
    
    originalChatContainerCenter = chatContainerView.center;
    
    [self.view addSubview:zoneView];
}

- (void)layoutChatViewW:(CGFloat)viewW viewH:(CGFloat)viewH {
    chatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    chatView.backgroundColor = [UIColor blueColor];
    chatView.tag = CHAT_VIEW;
}


- (void)layoutFeedViewW:(CGFloat)viewW viewH:(CGFloat)viewH {
    
    feedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    feedView.backgroundColor = [UIColor yellowColor];
    feedView.tag = FEED_VIEW;
}

#pragma mark - view transfer animation
- (void)transferFromView:(UIView *)view1 toView:(UIView *)view2 toLeft:(BOOL)toLeft {

    //NSUInteger index;
    
    //for(index = 0; [self.view.subviews objectAtIndex:index] != view1; ++index) {};
    
    // Remove old view
    [view1 removeFromSuperview];
    
    // Inser new view at right index
    //[self.view insertSubview:view2 atIndex:index];
    [self.view addSubview:view2];
    
    // Create the transition
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    [animation setType:kCATransitionPush];
    if (toLeft) {
        [animation setSubtype:kCATransitionFromLeft];
    } else {
        [animation setSubtype:kCATransitionFromRight];
    }
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setValue:self.view forKey:@"mainWindowViewChange"];
    [[self.view layer] addAnimation:animation forKey:@"transferViews"];
    
    currentView = (CurrentView)view2.tag;
    NSLog(@"current: %d", currentView);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"animation stoped");
    
    [self.view addGestureRecognizer:panG];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint velovity = [gestureRecognizer velocityInView:self.view];
    //CGPoint translation = [gestureRecognizer translationInView:self.view];

    //NSLog(@"translation: %f, %f", translation.x, translation.y);
    //NSLog(@"velovity: %f, %f", velovity.x, velovity.y);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        startPoint = [gestureRecognizer locationInView:self.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        endPoint = [gestureRecognizer locationInView:self.view];
        if (fabs(startPoint.x - endPoint.x) > 150 && fabs(startPoint.y - endPoint.y) < 50) {
            if (velovity.x > 0) {
                NSLog(@"to left view");
                if (currentView == ZONE_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:zoneView toView:feedView toLeft:YES];
                } else if (currentView == CHAT_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:chatView toView:zoneView toLeft:YES];
                } else if (currentView == FEED_VIEW) {
                    
                }
            } else {
                NSLog(@"to right view");
                if (currentView == ZONE_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:zoneView toView:chatView toLeft:NO];
                } else if (currentView == FEED_VIEW) {
                    [self.view removeGestureRecognizer:panG];
                    [self transferFromView:feedView toView:zoneView toLeft:NO];
                } else if (currentView == CHAT_VIEW) {
                            
                }
            }
        }
    }
}

- (void)handleDragClothPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    //CGPoint velovity = [gestureRecognizer velocityInView:self.view];
    //CGPoint translation = [gestureRecognizer translationInView:self.view];
    
    //NSLog(@"translation: %f, %f", translation.x, translation.y);
    //NSLog(@"velovity: %f, %f", velovity.x, velovity.y);
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //startPoint = [gestureRecognizer locationInView:self.view];
        dummyView = [[UIImageView alloc] initWithImage:clothImageView.image];
        dummyView.center = clothImageView.center;
        [zoneView addSubview:dummyView];
        [self changeAppearanceOfView:leftSideView alpha:1.0];
        [self changeAppearanceOfView:rightSideView alpha:1.0];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        dummyView.center = [gestureRecognizer locationInView:self.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [dummyView removeFromSuperview];
        CGPoint finalRightPoint = [rightSideView convertPoint:[gestureRecognizer locationInView:self.view] fromView:rightSideView.window];
        if ([rightSideView pointInside:finalRightPoint withEvent:nil]) {
            NSLog(@"send to chat");
            [chatInputTxtView becomeFirstResponder];
        }
        
        CGPoint finalLeftPoint = [leftSideView convertPoint:[gestureRecognizer locationInView:self.view] fromView:leftSideView.window];
        if ([leftSideView pointInside:finalLeftPoint withEvent:nil]) {
            NSLog(@"send to post");
        }
        
        [self changeAppearanceOfView:leftSideView alpha:0.0];
        [self changeAppearanceOfView:rightSideView alpha:0.0];
        
        
    }
}

- (void)changeAppearanceOfView:(UIView *)view alpha:(CGFloat)alpha {
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = alpha;
    }];
}

- (void)keyboardWillOpen:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        chatContainerView.alpha = 1.0;
    }];
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat yPosition = keyboardFrame.origin.y;
    
//    NSInteger height = [UIScreen mainScreen].bounds.size.height - yPosition;
    
    double animationDuration;
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    deltaY = chatContainerView.frame.origin.y + chatContainerView.frame.size.height - yPosition;
    
    if (deltaY > 0) {
        [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            chatContainerView.center = CGPointMake(chatContainerView.center.x, chatContainerView.center.y - deltaY);
        } completion:^(BOOL finished) {
            
        }];
    }

}

- (void)keyboardWillClose:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        chatContainerView.alpha = 0.0;
    }];
    
    double animationDuration;
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        chatContainerView.center = originalChatContainerCenter;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)keyboardDidClose:(NSNotification *)notification {
    
}

- (void)sendMessage {
    [chatInputTxtView resignFirstResponder];
    
}

@end
